# SPDX-FileCopyrightText: 2021 Serokell <https://serokell.io/>
#
# SPDX-License-Identifier: CC0-1.0
{
  description = "My haskell application";

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix?rev=d0b7bc42579a187e4753e459ef77dba6a1e9629e";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    haskellNix,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      overlays = [
        haskellNix.overlay
        (final: prev: {
          # This overlay adds our project to pkgs
          optim-jboProject =
            final.haskell-nix.project' {
              src = ./.;
              compiler-nix-name = "ghc96";
              # This is used by `nix develop .` to open a shell for use with
              # `cabal`, `hlint` and `haskell-language-server`
              shell = {
                tools = {
                  cabal = { };
                  #hlint = {};
                  fourmolu = { };
                  haskell-language-server = { };
                };
                buildInputs = with pkgs; [
                ];
              };
              # This adds `js-unknown-ghcjs-cabal` to the shell.
              # shell.crossPlatforms = p: [p.ghcjs];
            };
        })
      ];

      flake = pkgs.optim-jboProject.flake {
        # This adds support for `nix build .#js-unknown-ghcjs:optim-jbo:exe:optim-jbo`
        # crossPlatforms = p: [p.ghcjs];
      };



      #haskellPackages = pkgs.haskell.packages.ghc963;
      #haskellPackages = pkgs.haskellPackages;

      # jailbreakUnbreak = pkg:
      #   pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: {meta = {};}));

      # packageName = "static-ls";
    in  
      flake // {
        # Built by `nix build .`
        packages.default = flake.packages."static-ls:exe:static-ls";

        hydraJobs = { };
      }
    );

      # {
      # packages.${packageName} = pkgs.haskell.lib.dontCheck (haskellPackages.callCabal2nix packageName self rec {
      #   # Dependency overrides go here
      # });

      # packages.default = self.packages.${system}.${packageName};

      # devShells.default = pkgs.mkShell {
      #   buildInputs = with pkgs; [
      #     pkgs.haskell.packages.${pkgs.ghcVersion}.haskell-language-server # you must build it with your ghc to work
      #     haskellPackages.fourmolu
      #     haskellPackages.hiedb
      #     sqlite
      #     ghcid
      #     cabal-install
      #     hpack
      #     alejandra
      #   ];
      #   inputsFrom = [self.packages.${system}.${packageName}.env];
      #   shellHook = "PS1=\"[static-ls:\\w]$ \"";
      # };
    # });
}
