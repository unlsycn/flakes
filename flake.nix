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
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      user = "unlsycn";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;

      nixosConfigurations = pkgs.callPackage ./outputs/nixos.nix {
        inherit inputs user;
      };

      homeConfigurations = {
        ${user} = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = {
            inherit inputs;
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
