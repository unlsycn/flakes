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
    hyprland.url = "github:hyprwm/Hyprland";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    sops-nix.url = "github:Mic92/sops-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      ...
    }@inputs:
    let
      system1 = "x86_64-linux";
      user = "unlsycn";
      myPkgs = import nixpkgs {
        overlays = [
          (import ./pkgs { lib = nixpkgs.lib; })
          inputs.hyprland.overlays.default
        ];
        config = {
          allowUnfree = true;
        };
        system = system1;
      };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./outputs/nixos.nix
        ./outputs/home.nix
      ];
      _module.args = { inherit user; };

      perSystem =
        {
          inputs',
          pkgs,
          ...
        }:
        {
          _module.args.pkgs = myPkgs;

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
