{
  description = "UnlsycNix Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      user = "unlsycn";
      pkgs = import nixpkgs {
        overlays = [
          (import ./pkgs { lib = nixpkgs.lib; })
          inputs.hyprland.overlays.default
        ];
        config = {
          allowUnfree = true;
        };
        inherit system;
      };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      nixosConfigurations = pkgs.callPackage ./outputs/nixos.nix {
        inherit inputs user system;
      };

      homeConfigurations = {
        ${user} = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs system;
          };
          modules = [
            (pkgs.callPackage ./outputs/home.nix {
              inherit user inputs;
              profiles = [
                "desktop"
                "cli"
              ];
            }).users.${user}
          ];
        };
      };
    };
}
