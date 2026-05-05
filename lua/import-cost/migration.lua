---@class import-cost.Migration
---@field warn_if_github_source fun(root?: string)
---@field _test import-cost.MigrationTest

---@class import-cost.MigrationTest
---@field is_github_import_cost_source fun(url: string?): boolean
---@field marker_name string
---@field session_key string

local M = {}

---@type string
local marker_name = 'github-source-migration-v1'
---@type string
local migration_help = ':help import-cost.nvim-migration'
---@type string
local session_key = 'import_cost_github_source_migration_warned'

---@return string?
local function plugin_root()
  local source = debug.getinfo(1, 'S').source
  if type(source) ~= 'string' or source:sub(1, 1) ~= '@' then
    return nil
  end
  return vim.fn.fnamemodify(source:sub(2), ':h:h:h')
end

---@param root string?
---@return string?
local function origin_url(root)
  if type(root) ~= 'string' or root == '' or vim.fn.executable('git') ~= 1 then
    return nil
  end

  local output = vim.fn.system({ 'git', '-C', root, 'config', '--get', 'remote.origin.url' })
  if vim.v.shell_error ~= 0 then
    return nil
  end

  output = vim.trim(output or '')
  if output == '' then
    return nil
  end
  return output
end

---@param url string?
---@return boolean
local function is_github_import_cost_source(url)
  if type(url) ~= 'string' then
    return false
  end

  local normalized = url:lower():gsub('%.git$', '')
  return normalized == 'https://github.com/barrettruth/import-cost.nvim'
    or normalized == 'http://github.com/barrettruth/import-cost.nvim'
    or normalized == 'git://github.com/barrettruth/import-cost.nvim'
    or normalized == 'ssh://git@github.com/barrettruth/import-cost.nvim'
    or normalized == 'git@github.com:barrettruth/import-cost.nvim'
    or normalized == 'https://github.com/barrett-ruth/import-cost.nvim'
    or normalized == 'http://github.com/barrett-ruth/import-cost.nvim'
    or normalized == 'git://github.com/barrett-ruth/import-cost.nvim'
    or normalized == 'ssh://git@github.com/barrett-ruth/import-cost.nvim'
    or normalized == 'git@github.com:barrett-ruth/import-cost.nvim'
end

---@return string?
local function marker_path()
  local ok, state = pcall(vim.fn.stdpath, 'state')
  if not ok or type(state) ~= 'string' or state == '' then
    return nil
  end
  return state .. '/import-cost.nvim/' .. marker_name
end

---@param path string?
---@return boolean
local function marker_exists(path)
  return path ~= nil and vim.uv.fs_stat(path) ~= nil
end

---@param path string?
local function touch_marker(path)
  if not path then
    return
  end

  local dir = vim.fn.fnamemodify(path, ':h')
  pcall(vim.fn.mkdir, dir, 'p')

  local file = io.open(path, 'w')
  if file then
    local timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    if type(timestamp) ~= 'string' then
      timestamp = ''
    end
    file:write(timestamp)
    file:write('\n')
    file:close()
  end
end

---@param root string?
function M.warn_if_github_source(root)
  if vim.g[session_key] then
    return
  end

  local marker = marker_path()
  if marker_exists(marker) then
    return
  end

  if not is_github_import_cost_source(origin_url(root or plugin_root())) then
    return
  end

  vim.g[session_key] = true
  touch_marker(marker)

  vim.notify(
    (
      "[import-cost.nvim]: Due to GitHub's historic unreliability, development "
      .. 'has moved to Forgejo. See %s to optionally update your plugin '
      .. 'source configuration. This is a one-time warning.'
    ):format(migration_help),
    vim.log.levels.WARN
  )
end

---@type import-cost.MigrationTest
M._test = {
  is_github_import_cost_source = is_github_import_cost_source,
  marker_name = marker_name,
  session_key = session_key,
}

return M
