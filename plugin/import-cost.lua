if vim.g.loaded_import_cost then
    return
end
vim.g.loaded_import_cost = 1

vim.api.nvim_create_autocmd('FileType', {
    pattern = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'svelte',
    },
    callback = function(args)
        require('import-cost').attach(args.buf)
    end,
})
