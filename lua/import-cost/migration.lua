local M = {}

local message = table.concat({
  '[import-cost.nvim] This repository will be removed from GitHub on October 31, 2026.',
  'Install from Forgejo: https://forge.barrettruth.com/barrettruth/import-cost.nvim.',
  'See :help import-cost-migration.',
}, ' ')

---@param origin unknown
---@return boolean
function M.is_github_origin(origin)
  if type(origin) ~= 'string' then
    return false
  end

  origin = origin:gsub('/+$', ''):gsub('%.git$', '')

  return origin == 'https://github.com/barrettruth/import-cost.nvim'
    or origin == 'http://github.com/barrettruth/import-cost.nvim'
    or origin == 'git://github.com/barrettruth/import-cost.nvim'
    or origin == 'ssh://git@github.com/barrettruth/import-cost.nvim'
    or origin == 'git@github.com:barrettruth/import-cost.nvim'
    or origin == 'https://github.com/barrett-ruth/import-cost.nvim'
    or origin == 'http://github.com/barrett-ruth/import-cost.nvim'
    or origin == 'git://github.com/barrett-ruth/import-cost.nvim'
    or origin == 'ssh://git@github.com/barrett-ruth/import-cost.nvim'
    or origin == 'git@github.com:barrett-ruth/import-cost.nvim'
end

---@return string
function M.plugin_root()
  local source = debug.getinfo(1, 'S').source:sub(2)
  return vim.fs.dirname(vim.fs.dirname(vim.fs.dirname(source)))
end

---@param root string
---@param callback fun(origin: string)
---@return nil
function M.origin(root, callback)
  if vim.fn.executable('git') ~= 1 then
    return
  end

  pcall(
    vim.system,
    { 'git', '-C', root, 'config', '--get', 'remote.origin.url' },
    { text = true },
    function(result)
      if result.code == 0 and result.stdout then
        callback(vim.trim(result.stdout))
      end
    end
  )
end

---@param root? string
---@return nil
function M.warn_if_github_source(root)
  M.origin(root or M.plugin_root(), function(origin)
    if M.is_github_origin(origin) then
      vim.schedule(function()
        vim.notify_once(message, vim.log.levels.WARN)
      end)
    end
  end)
end

return M
