# import-cost.nvim

Display javascript import costs inside neovim, powered by
[import-cost](https://github.com/wix/import-cost).

![preview](https://user-images.githubusercontent.com/62671086/210295248-916a8d81-22c9-432a-87fd-cf539879bf0c.png)

## Installation

Install with your package manager or via
[luarocks](https://luarocks.org/modules/barrettruth/import-cost.nvim):

```
:Rocks install import-cost.nvim
```

Dependencies are installed automatically on first use.

## Documentation

```vim
:help import-cost.nvim
```

## Known Issues

1. CommonJS support is flaky (limitation of the npm module)
2. Long wait times for large packages
3. [pnpm not supported](https://github.com/barrett-ruth/import-cost.nvim/issues/5)

## Acknowledgements

- [wix/import-cost](https://github.com/wix/import-cost/): node backend
- [import-cost](https://marketplace.visualstudio.com/items?itemName=wix.vscode-import-cost):
  original VSCode plugin
- [vim-import-cost](https://github.com/yardnsm/vim-import-cost): vim inspiration
