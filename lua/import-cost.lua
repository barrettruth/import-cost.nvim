local M = {}

local initialized = false
local building = false
local attached_bufs = {}
local pending_bufs = {}

local defaults = {
  package_manager = 'npm',
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

local plugin_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h')

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

local function setup_autocmds()
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
end

local function finish_init()
  M.ns_id = vim.api.nvim_create_namespace('ImportCost')
  M.aug_id = vim.api.nvim_create_augroup('ImportCost', {})

  vim.api.nvim_set_hl(
    0,
    'ImportCostVirtualText',
    ---@diagnostic disable-next-line: param-type-mismatch
    type(M.config.highlight) == 'string' and { link = M.config.highlight } or M.config.highlight
  )

  setup_autocmds()
  initialized = true

  for _, bufnr in ipairs(pending_bufs) do
    M.attach(bufnr)
  end
  pending_bufs = {}
end

local function build(on_complete)
  if building then
    return
  end
  building = true

  local import_cost_dir = plugin_dir .. '/import-cost'
  local pm = M.config.package_manager

  vim.notify('import-cost.nvim: Building (first run)...', vim.log.levels.INFO)

  local function install_deps()
    vim.system({ pm, 'install' }, { cwd = import_cost_dir }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify('import-cost.nvim: Failed to install dependencies', vim.log.levels.ERROR)
          building = false
          return
        end

        local src = plugin_dir .. '/index.js'
        local dst = import_cost_dir .. '/index.js'
        vim.uv.fs_copyfile(src, dst, function(err)
          vim.schedule(function()
            building = false
            if err then
              vim.notify('import-cost.nvim: Failed to copy index.js', vim.log.levels.ERROR)
            else
              vim.notify('import-cost.nvim: Ready', vim.log.levels.INFO)
              if on_complete then
                on_complete()
              end
            end
          end)
        end)
      end)
    end)
  end

  if vim.fn.isdirectory(import_cost_dir) == 0 then
    vim.system(
      { 'git', 'clone', 'https://github.com/wix/import-cost.git', import_cost_dir },
      {},
      function(result)
        vim.schedule(function()
          if result.code ~= 0 then
            vim.notify('import-cost.nvim: Failed to clone wix/import-cost', vim.log.levels.ERROR)
            building = false
            return
          end
          install_deps()
        end)
      end
    )
  else
    install_deps()
  end
end

local function init()
  if initialized then
    return true
  end

  local user_config = vim.g.import_cost or {}
  M.config = vim.tbl_deep_extend('force', M.config, user_config)

  M.script_path = plugin_dir .. '/import-cost/index.js'

  if not vim.uv.fs_stat(M.script_path) then
    build(finish_init)
    return false
  end

  finish_init()
  return true
end

---@deprecated Use `vim.g.import_cost` instead
M.setup = function(user_config)
  vim.deprecate(
    'require("import-cost").setup()',
    'vim.g.import_cost',
    'v0.1.0',
    'import-cost.nvim',
    false
  )

  vim.notify_once(
    [[import-cost.nvim: Migration required

Before:
  require('import-cost').setup({ ... })
  build = 'sh scripts/install.sh yarn'

After:
  vim.g.import_cost = {
    package_manager = 'yarn',  -- npm, yarn, or bun
    -- ... other options
  }

Dependencies now install automatically. Remove the `build` option.]],
    vim.log.levels.WARN
  )

  if user_config then
    vim.g.import_cost = vim.tbl_deep_extend('force', vim.g.import_cost or {}, user_config)
  end

  init()
end

function M.attach(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if attached_bufs[bufnr] then
    return
  end

  if not is_ic_buf(bufnr) then
    return
  end

  if not init() then
    table.insert(pending_bufs, bufnr)
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
