{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
{
  config = mkIf config.programs.nvf.enable {
    programs.nvf.settings = {
      imports = [ ./common.nix ];

      vim = {
        theme = {
          enable = true;
          name = "catppuccin";
          style = "macchiato";
        };

        lsp = {
          enable = true;
          formatOnSave = true;
          inlayHints = true;
          trouble.enable = true;
          lspSignature.enable = true;
        };

        statusline.lualine.enable = true;
        tabline.nvimBufferline = {
          enable = true;
          setupOpts.options.numbers = "none";
        };
        telescope = {
          enable = true;
          mappings = {
            findFiles = "<C-p>";
            liveGrep = "<C-F>";
          };
          setupOpts.defaults = {
            color_devicons = true;
          };
          extensions = [
            {
              name = "fzf";
              packages = with pkgs.vimPlugins; [ telescope-fzf-native-nvim ];
              setup = {
                fzf = {
                  fuzzy = true;
                };
              };
            }
          ];
        };
        autocomplete.blink-cmp = {
          enable = true;
          mappings = {
            complete = "<C-Space>";
            confirm = "<Tab>";
            next = "<C-CR>";
            previous = "<S-CR>";
          };
        };
        comments.comment-nvim = {
          enable = true;
          mappings = {
            toggleCurrentLine = "<C-_>";
            toggleSelectedBlock = "<C-_>";
            toggleSelectedLine = "<C-_>";
          };
        };
        autopairs.nvim-autopairs.enable = true;
        git.neogit.enable = true;
        binds.whichKey.enable = true;
        filetree.nvimTree = {
          enable = true;
          mappings = {
            toggle = "<C-w>e";
            findFile = "<C-w>f";
          };
          setupOpts = {
            tab.sync = {
              open = true;
              close = true;
            };
            view.side = "right";
            renderer = {
              highlight_modified = "name";
              highlight_opened_files = "none";
              icons.show = {
                git = true;
                modified = true;
              };
            };
          };
        };
        ui.illuminate.enable = true;
        utility = {
          direnv.enable = true;
          undotree.enable = true;
          sleuth.enable = true;
        };
        languages = {
          enableTreesitter = true;
          enableFormat = true;
          nix = {
            enable = true;
            format.type = [ "nixfmt" ];
          };
          markdown.enable = true;
          bash.enable = true;
          scala.enable = true;
          rust.enable = true;
          clang.enable = true;
          ocaml.enable = true;
          json.enable = true;
          yaml.enable = true;
          zig.enable = true;
        };

        keymaps = [
          {
            key = "<C-s>";
            mode = [
              "n"
              "i"
              "v"
            ];
            action = "<cmd>write<cr>";
            desc = "Save file";
          }
        ];
      };
    };
  };
}
