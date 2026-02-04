# import-cost.nvim

Display the costs of javascript imports inside neovim with the power of
[import-cost](https://github.com/wix/import-cost/tree/master/packages/import-cost).

![preview](https://user-images.githubusercontent.com/62671086/210295248-916a8d81-22c9-432a-87fd-cf539879bf0c.png)

## Installation

Install with your preferred package manager:

```lua
-- lazy.nvim
{
    'barrett-ruth/import-cost.nvim',
    build = 'sh scripts/install.sh yarn',
    -- if on windows
    -- build = 'pwsh scripts/install.ps1 yarn',
}

-- rocks.nvim
:Rocks install import-cost.nvim
```

**Note**: pnpm is not supported because
[import-cost](https://github.com/wix/import-cost) does not support it.

## Configuration

Configure via `vim.g.import_cost`:

```lua
vim.g.import_cost = {
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
```

See `:h import-cost` for more information.

## Known Issues

1. CommonJS support is particularly flaky - some packages work, some dont (this
   is by virtue of the [npm module](https://github.com/wix/import-cost/), and,
   thus, unavoidable)
2. Long wait times - once again, the npm module may take quite a while before
   fully parsing packages
3. [pnpm problems](https://github.com/barrett-ruth/import-cost.nvim/issues/5)

## Acknowledgements

1. [wix/import-cost](https://github.com/wix/import-cost/): provides the node
   backend that calculates the import costs
2. [import-cost](https://marketplace.visualstudio.com/items?itemName=wix.vscode-import-cost):
   the original VSCode plugin that started it all
3. [vim-import-cost](https://github.com/yardnsm/vim-import-cost): inspired me to
   do it in neovim!
