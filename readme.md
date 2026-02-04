# import-cost.nvim

Display the costs of JavaScript imports inside Neovim with the power of
[import-cost](https://github.com/wix/import-cost/tree/master/packages/import-cost).

![preview](https://user-images.githubusercontent.com/62671086/210295248-916a8d81-22c9-432a-87fd-cf539879bf0c.png)

## Installation

Install using your package manager of choice or via [luarocks](https://luarocks.org/modules/barrettruth/import-cost.nvim):

```
luarocks install import-cost.nvim
```

After installing, run the install script with your node.js package manager:

```sh
sh install.sh yarn  # or npm
```

Note: pnpm is not supported due to [import-cost limitations](https://github.com/wix/import-cost).

## Configuration

Configure via `vim.g.import_cost` before the plugin loads:

```lua
vim.g.import_cost = {
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'svelte' },
  format = {
    byte_format = '%.1fb',
    kb_format = '%.1fk',
    virtual_text = '%s (gzipped: %s)',
  },
  highlight = 'Comment',
}
```

See `:help import-cost` for more information.

## Known Issues

1. CommonJS support is flaky due to the underlying npm module
2. Long wait times for some packages
3. [pnpm problems](https://github.com/barrettruth/import-cost.nvim/issues/5)

## Documentation

```vim
:help import-cost.nvim
```
