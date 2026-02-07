{
  pkgs,
  ...
}:
let
  vim-verible-format = pkgs.vimUtils.buildVimPlugin {
    name = "vim-verible-format";
    src = pkgs.fetchFromGitHub {
      owner = "unlsycn";
      repo = "vim-verible-format";
      rev = "master";
      hash = "sha256-3EIVI5i7IdJmqD36HJZ3O+B6BZvGudjM0dQCjqcBwg4=";
    };
  };
in
{
  imports = [ ./options.nix ];

  vim = {
    options = {
      shiftwidth = 4;
      tabstop = 4;
      ignorecase = true;
      smartcase = true;
      guicursor = "i:hor20,n-v:block";
    };

    globals = {
      mapleader = ";";
    };

    keymaps = [
      {
        key = ";";
        mode = "n";
        action = ":";
        desc = "CMD enter command mode";
      }
    ];

    utility.motion.leap.enable = true;

    lazy.plugins = with pkgs.vimPlugins; {
      "flit.nvim" = {
        package = flit-nvim;
        after = "require('flit').setup()";
      };

      "vim-sandwich" = {
        package = vim-sandwich;
        keys = [
          {
            key = "<leader>a";
            mode = [
              "n"
              "x"
              "o"
            ];
            action = "<Plug>(sandwich-add)";
          }
          {
            key = "<leader>d";
            mode = [
              "n"
              "x"
            ];
            action = "<Plug>(sandwich-delete)";
          }
          {
            key = "<leader>r";
            mode = [
              "n"
              "x"
            ];
            action = "<Plug>(sandwich-replace)";
          }
          {
            key = "<leader>db";
            mode = "n";
            action = "<Plug>(sandwich-delete-auto)";
          }
          {
            key = "<leader>rb";
            mode = "n";
            action = "<Plug>(sandwich-replace-auto)";
          }
        ];

        globals = {
          operator_sandwich_no_default_key_mappings = true;
        };

        after = ''
          local api = vim.api
          api.nvim_set_hl(0, "OperatorSandwichBuns", { fg = "#aa91a0", underline = true, ctermfg = 172, cterm = {underline = true} })
          api.nvim_set_hl(0, "OperatorSandwichChange", { fg = "#edc41f", underline = true, ctermfg = "yellow", cterm = {underline = true} })
          api.nvim_set_hl(0, "OperatorSandwichAdd", { fg = "#b1fa87", underline = false, ctermfg = "green" })
          api.nvim_set_hl(0, "OperatorSandwichDelete", { fg = "#cf5963", underline = false, ctermfg = "red" })
        '';
      };

      "camelcasemotion" = {
        package = camelcasemotion;
        globals = {
          camelcasemotion_key = "<leader>";
        };
      };

      "vimplugin-vim-verible-format" = {
        package = vim-verible-format;
        globals = {
          verible_format_arguments = "--column_limit=80 --indentation_spaces=4";
        };
        cmd = [ "VeribleFormat" ];
      };

      "vim-indent-object" = {
        package = vim-indent-object;
        event = [
          {
            event = "User";
            pattern = "LazyFile";
          }
        ];
      };

      "vim-textobj-entire" = {
        package = vim-textobj-entire;
        event = [
          {
            event = "User";
            pattern = "LazyFile";
          }
        ];
      };

      "vim-visual-multi" = {
        package = vim-visual-multi;
        globals = {
          VM_leader = ''\'';
          VM_theme = "neon";
        };
        event = [
          {
            event = "User";
            pattern = "LazyFile";
          }
        ];
      };
    };

    luaConfigRC.clipboard = ''
      local copy = "wl-copy"
      local paste = "wl-paste"
      if os.getenv('SSH_TTY') ~= nil then
        function my_paste(reg)
          return function(lines)
            local content = vim.fn.getreg('"')
            return vim.split(content, '\n')
          end
        end

        vim.opt.clipboard:append("unnamedplus")
        vim.g.clipboard = {
          name = 'OSC 52',
          copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
            ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
          },
          paste = {
            ["+"] = my_paste(),
            ["*"] = my_paste(),
          },
        }
      else
        if vim.fn.executable(copy) == 1 and vim.fn.executable(paste) == 1 then
          vim.opt.clipboard = "unnamedplus"
          vim.g.clipboard = {
            name = 'wl-clipboard',
            copy = {
              ["+"] = copy,
              ["*"] = copy,
            },
            paste = {
              ["+"] = paste .. " -n",
              ["*"] = paste .. " -n",
            },
            cache_enabled = true,
          }
        end
      end
    '';
  };
}
