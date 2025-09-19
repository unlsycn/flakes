{
  description = "UnlsycNix Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    sops-nix.url = "github:Mic92/sops-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    jovian-nixos.url = "github:unlsycn/Jovian-NixOS";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-dram = {
      url = "github:dramforever/nix-dram";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    let
      user = "unlsycn";
      overlays = import ./overlays {
        lib = nixpkgs.lib;
        inherit inputs;
      };
      overlaysList = builtins.attrValues overlays ++ [ inputs.nix-dram.overlay ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./system
        ./home
        ./outputs/nixos.nix
        ./outputs/home.nix
      ];
      _module.args = { inherit user; };

      flake =
        { lib, ... }:
        with lib;
        {
          options.buildConfigurationPhases = with types; mkOption { type = attrsOf raw; };

          config = {
            inherit overlays;
          };
        };

      perSystem =
        {
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = overlaysList;
            config = {
              allowUnfree = true;
            };
          };

          formatter = pkgs.nixfmt-rfc-style;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              nixd
              home-manager
              nvfetcher
              sops
            ];

            nativeBuildInputs = [ inputs'.sops-nix.packages.sops-import-keys-hook ];
          };
        };
    };
}
