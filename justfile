default:
    @just --list

format:
    nix fmt -- --ci
    stylua --check .
    biome format .
    vimdoc-language-server format --check doc/

lint:
    git ls-files '*.lua' | xargs selene --display-style quiet
    lua-language-server --check . --configpath "$(pwd)/.luarc.json" --checklevel=Warning
    vimdoc-language-server check doc/

ci: format lint
    @:
