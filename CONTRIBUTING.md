# Contributing

Development, issues, and pull requests happen on
[Forgejo](https://git.barrettruth.com/barrettruth/import-cost.nvim).

## Scope

import-cost.nvim is a compact Neovim integration for displaying JavaScript
import costs. It is not a bundler, package analyzer, or general diagnostics
framework.

## Pull Requests

Bug fixes and documentation fixes are welcome. AI-generated contributions are
not accepted.

For new behavior, open an issue first unless the change is small and already
fits the project's scope.

Behavior or configuration changes should update `README.md` and
`doc/import-cost.nvim.txt` when appropriate.

## Development

It is preferred to use the Nix development shell, which bundles all necessary
tools:

```sh
nix develop
```

## Checks

Run the local checks before opening a pull request:

```sh
nix develop --command just ci
```
