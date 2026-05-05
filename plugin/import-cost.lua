if vim.g.loaded_import_cost then
  return
end
vim.g.loaded_import_cost = 1

pcall(function()
  require('import-cost.migration').warn_if_github_source()
end)

local user_config = vim.g.import_cost or {}
local filetypes = user_config.filetypes
  or {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'svelte',
  }

vim.api.nvim_create_autocmd('FileType', {
  pattern = filetypes,
  callback = function(args)
    require('import-cost').attach(args.buf)
  end,
})
