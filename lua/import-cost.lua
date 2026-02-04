local M = {}

local initialized = false
local attached_bufs = {}

local defaults = {
    filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'svelte',
    },
    format = {
        byte_format = '%.1fb',
        kb_format = '%.1fk',
        virtual_text = '%s (gzipped: %s)',
    },
    highlight = 'Comment',
}

M.config = vim.deepcopy(defaults)
M.ns_id = nil
M.aug_id = nil
M.script_path = nil

local function is_ic_buf(bufnr)
    local ok, filetype = pcall(vim.api.nvim_get_option_value, 'filetype', { buf = bufnr })

    if not ok then
        return false
    end

    return vim.tbl_contains(M.config.filetypes, filetype)
end

local function au(events, cb)
    vim.api.nvim_create_autocmd(events, {
        callback = function(opts)
            if is_ic_buf(opts.buf) then
                cb(opts.buf)
            end
        end,
        group = M.aug_id,
    })
end

local function init()
    if initialized then
        return true
    end

    M.script_path = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h')
        .. '/import-cost/index.js'

    if not vim.loop.fs_stat(M.script_path) then
        vim.notify_once(
            string.format(
                'import-cost.nvim: Failed to load script at %s. Ensure the plugin is properly installed.',
                M.script_path
            ),
            vim.log.levels.ERROR
        )
        return false
    end

    local user_config = vim.g.import_cost or {}
    M.config = vim.tbl_deep_extend('force', M.config, user_config)

    M.ns_id = vim.api.nvim_create_namespace('ImportCost')
    M.aug_id = vim.api.nvim_create_augroup('ImportCost', {})

    vim.api.nvim_set_hl(
        0,
        'ImportCostVirtualText',
        ---@diagnostic disable-next-line: param-type-mismatch
        type(M.config.highlight) == 'string' and { link = M.config.highlight }
            or M.config.highlight
    )

    local extmark = require('import-cost.extmark')

    au('BufEnter', function(bufnr)
        extmark.set_extmarks(bufnr)
    end)

    au('InsertEnter', function(bufnr)
        extmark.delete_extmarks(bufnr)
    end)

    au('InsertLeave', function(bufnr)
        extmark.set_extmarks(bufnr)
    end)

    au('TextChanged', function(bufnr)
        extmark.delete_extmarks(bufnr)
        extmark.set_extmarks(bufnr)
    end)

    initialized = true
    return true
end

---@deprecated Use `vim.g.import_cost` instead
M.setup = function(user_config)
    vim.deprecate('require("import-cost").setup()', 'vim.g.import_cost', 'v0.1.0', 'import-cost.nvim', false)

    if user_config then
        vim.g.import_cost = vim.tbl_deep_extend('force', vim.g.import_cost or {}, user_config)
    end

    init()
end

function M.attach(bufnr)
    if not init() then
        return
    end

    bufnr = bufnr or vim.api.nvim_get_current_buf()

    if attached_bufs[bufnr] then
        return
    end

    if not is_ic_buf(bufnr) then
        return
    end

    attached_bufs[bufnr] = true

    local extmark = require('import-cost.extmark')
    extmark.set_extmarks(bufnr)

    vim.api.nvim_create_autocmd('BufWipeout', {
        buffer = bufnr,
        group = M.aug_id,
        callback = function()
            attached_bufs[bufnr] = nil
        end,
    })
end

return M
