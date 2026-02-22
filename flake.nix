{
  description = "UnlsycNix Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian-nixos = {
      url = "github:unlsycn/Jovian-NixOS";
      # TODO: follow nixpkgs
    };
    foundryvtt = {
      url = "github:reckenrode/nix-foundryvtt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    harmonia = {
      url = "github:nix-community/harmonia";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    buildbot-nix = {
      url = "github:nix-community/buildbot-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    nix-dram = {
      url = "github:dramforever/nix-dram";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ssh-keys = {
      url = "https://github.com/unlsycn.keys";
      flake = false;
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
      overlaysList = builtins.attrValues overlays ++ [
        inputs.nix-dram.overlay
        inputs.vscode-extensions.overlays.default
      ];
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./system
        ./home
        ./outputs/nixos.nix
        ./outputs/home.nix
        ./outputs/topology.nix
        inputs.git-hooks.flakeModule
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
          config,
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

          formatter = pkgs.nixfmt;

          apps.update-nebula-certs = {
            type = "app";
            program = "${pkgs.callPackage ./scripts/update-nebula-certs.nix { }}/bin/update-nebula-certs";
          };

          pre-commit = {
            check.enable = false;
            settings = {
              hooks.nebula-certs = {
                enable = true;
                name = "nebula-certs";
                entry = config.apps.update-nebula-certs.program;
                pass_filenames = false;
              };
            };
          };

          devShells.default = pkgs.mkShell {
            shellHook = config.pre-commit.installationScript;
            packages = with pkgs; [
              nixd
              home-manager
              nvfetcher
              sops
              disko
              nebula
              deploy-rs
            ];

            nativeBuildInputs = [ inputs'.sops-nix.packages.sops-import-keys-hook ];
          };
        };
    };
}
