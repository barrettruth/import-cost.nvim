{
  description = "import-cost.nvim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      nixpkgs,
      systems,
      ...
    }:
    let
      forEachSystem =
        f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
    in
    {
      formatter = forEachSystem (pkgs: pkgs.nixfmt-tree);

      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.just
            pkgs.biome
            pkgs.stylua
            pkgs.neovim
            pkgs.selene
            pkgs.lua-language-server
            pkgs.vimdoc-language-server
          ];
        };

        ci = pkgs.mkShell {
          packages = [
            pkgs.just
            pkgs.biome
            pkgs.stylua
            pkgs.neovim
            pkgs.selene
            pkgs.lua-language-server
            pkgs.vimdoc-language-server
          ];
        };
      });
    };
}
