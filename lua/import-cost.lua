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

local config = vim.deepcopy(defaults)
local ns_id = nil
local aug_id = nil
local script_path = nil

local function init()
  if initialized then
    return true
  end

  script_path = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':h:h') .. '/import-cost/index.js'

  if not vim.loop.fs_stat(script_path) then
    vim.notify_once(
      string.format('import-cost.nvim: Failed to load script at %s. Ensure the plugin is properly installed.', script_path),
      vim.log.levels.ERROR
    )
    return false
  end

  local user_config = vim.g.import_cost or {}
  config = vim.tbl_deep_extend('force', defaults, user_config)

  ns_id = vim.api.nvim_create_namespace('ImportCost')
  aug_id = vim.api.nvim_create_augroup('ImportCost', {})

  vim.api.nvim_set_hl(
    0,
    'ImportCostVirtualText',
    type(config.highlight) == 'string' and { link = config.highlight } or config.highlight
  )

  initialized = true
  return true
end

local function is_supported_filetype(bufnr)
  local ok, ft = pcall(vim.api.nvim_get_option_value, 'filetype', { buf = bufnr })
  if not ok then
    return false
  end
  return vim.tbl_contains(config.filetypes, ft)
end

function M.attach(bufnr)
  if not init() then
    return
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if attached_bufs[bufnr] then
    return
  end

  if not is_supported_filetype(bufnr) then
    return
  end

  attached_bufs[bufnr] = true

  local extmark = require('import-cost.extmark')

  extmark.set_extmarks(bufnr)

  vim.api.nvim_create_autocmd('BufEnter', {
    buffer = bufnr,
    group = aug_id,
    callback = function()
      extmark.set_extmarks(bufnr)
    end,
  })

  vim.api.nvim_create_autocmd('InsertEnter', {
    buffer = bufnr,
    group = aug_id,
    callback = function()
      extmark.delete_extmarks(bufnr)
    end,
  })

  vim.api.nvim_create_autocmd('InsertLeave', {
    buffer = bufnr,
    group = aug_id,
    callback = function()
      extmark.set_extmarks(bufnr)
    end,
  })

  vim.api.nvim_create_autocmd('TextChanged', {
    buffer = bufnr,
    group = aug_id,
    callback = function()
      extmark.delete_extmarks(bufnr)
      extmark.set_extmarks(bufnr)
    end,
  })

  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = bufnr,
    group = aug_id,
    callback = function()
      attached_bufs[bufnr] = nil
    end,
  })
end

function M.get_config()
  return config
end

function M.get_ns_id()
  init()
  return ns_id
end

function M.get_script_path()
  init()
  return script_path
end

return M
