{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.vscode;
in
{
  imports = [ ./hyprland.nix ];

  options.programs.vscode = {
    continue.enable = mkEnableOption "Continue extension for VSCode";
    useAntigravity = mkOption {
      type = types.bool;
      default = false;
      description = "Use Antigravity instead of VSCode";
    };
  };

  config = mkIf cfg.enable {
    home.persistence."/persist" = {
      directories = [
        cfg.dataFolderName
        ".config/${cfg.nameShort}"
      ]
      ++ optionals cfg.useAntigravity [
        ".gemini/antigravity"
        ".gemini/antigravity-browser-profile"
      ]
      ++ optional cfg.continue.enable ".continue";
      files = optional cfg.useAntigravity ".gemini/GEMINI.md";
    };

    programs.vscode = {
      package =
        let
          basePackage = if cfg.useAntigravity then pkgs.antigravity else pkgs.vscode;
          overrideForContinue =
            pkg:
            pkg.overrideAttrs (
              final: prev: {
                preFixup =
                  prev.preFixup
                  + "gappsWrapperArgs+=( --prefix LD_LIBRARY_PATH : ${makeLibraryPath [ pkgs.gcc.cc.lib ]} )";
              }
            );
        in
        if cfg.continue.enable then basePackage |> overrideForContinue else basePackage;

      mutableExtensionsDir = false;

      profiles.default = {
        extensions =
          with pkgs.nix-vscode-extensions.vscode-marketplace-release;
          [
            # Themes
            arcticicestudio.nord-visual-studio-code
            whizkydee.material-palenight-theme
            luqimin.tiny-light
            pkief.material-icon-theme

            # Git & Version Control
            eamodio.gitlens
            donjayamanne.githistory
            wdhongtw.gpg-indicator
            github.vscode-pull-request-github
            github.vscode-github-actions

            # Editor Tools
            asvetliakov.vscode-neovim
            julianiaquinandi.nvim-ui-modifier
            usernamehw.errorlens
            gruntfuggly.todo-tree
            adpyke.codesnap
            sirtori.indenticator
            mkxml.vscode-filesize
            lacroixdavid1.vscode-format-context-menu
            streetsidesoftware.code-spell-checker
            vivaxy.vscode-conventional-commits

            # Docker & Containers
            ms-azuretools.vscode-docker
            ms-azuretools.vscode-containers
            docker.docker

            # Programming Languages
            # Python
            ms-python.python
            ms-python.vscode-pylance
            ms-python.isort
            ms-python.pylint
            eeyore.yapf
            rickaym.manim-sideview

            # JavaScript / TypeScript
            esbenp.prettier-vscode
            dbaeumer.vscode-eslint
            angular.ng-template

            # Go
            golang.go

            # Rust
            rust-lang.rust-analyzer

            # C/C++
            llvm-vs-code-extensions.vscode-clangd
            jeff-hykin.better-cpp-syntax
            ms-vscode.cmake-tools
            twxs.cmake

            # C#
            # FIXME: https://github.com/nix-community/nix-vscode-extensions/issues/109
            # ms-dotnettools.csharp
            # ms-dotnettools.vscode-dotnet-runtime

            # Scala
            scalameta.metals
            scala-lang.scala

            # OCaml
            ocamllabs.ocaml-platform

            # Zig
            ziglang.vscode-zig

            # Idris
            bamboo.idris2-lsp

            # Lua
            sumneko.lua

            # Nix
            jnoortheen.nix-ide
            mkhl.direnv

            # Typst
            myriad-dreamin.tinymist

            # Hardware Description Languages
            mshr-h.veriloghdl
            zhwu95.riscv

            # LLVM
            llvm-vs-code-extensions.vscode-mlir
            jakob-erzar.llvm-tablegen
            pkgs.nix-vscode-extensions.vscode-marketplace-release."13xforever".language-x86-64-assembly

            # Wolfram Language
            lsp-wl.lsp-wl-client
            shigma.vscode-wl

            # Kotlin
            mathiasfrohlich.kotlin

            # Web Development
            ecmel.vscode-html-css
            hollowtree.vue-snippets
            ritwickdey.liveserver
            foxundermoon.shell-format

            # Markdown & Documentation
            davidanson.vscode-markdownlint
            shd101wyy.markdown-preview-enhanced
            bierner.markdown-mermaid
            gera2ld.markmap-vscode

            # Data Formats
            tamasfe.even-better-toml
            redhat.vscode-yaml
            redhat.vscode-xml
            redhat.vscode-commons

            # Jupyter Notebooks
            ms-toolsai.jupyter
            ms-toolsai.jupyter-keymap
            ms-toolsai.jupyter-renderers
            ms-toolsai.vscode-jupyter-cell-tags
            ms-toolsai.vscode-jupyter-slideshow

            # Utilities
            ms-vscode.hexeditor
            mateuszchudyk.hexinspector
            ibm.output-colorizer
            kamikillerto.vscode-colorize
            anseki.vscode-color
            christian-kohler.path-intellisense
            ajshort.include-autocomplete
            rioj7.vscode-remove-comments
            wakatime.vscode-wakatime
          ]
          ++ lib.optional (!cfg.useAntigravity) [
            # LLM Assistant
            github.copilot-chat

            # Remote Development
            ms-vscode-remote.remote-ssh
            ms-vscode-remote.remote-ssh-edit
            ms-vscode-remote.remote-containers
            ms-vscode-remote.remote-wsl
            ms-vscode.remote-explorer
          ];

        userSettings =
          let
            # Terminal
            terminal = {
              # Profiles - Windows
              "terminal.integrated.profiles.windows" = {
                "PowerShell" = {
                  source = "PowerShell";
                  icon = "terminal-powershell";
                };
                "Command Prompt" = {
                  path = [
                    "\${env:windir}\\Sysnative\\cmd.exe"
                    "\${env:windir}\\System32\\cmd.exe"
                  ];
                  args = [ ];
                  icon = "terminal-cmd";
                };
                "Git Bash" = {
                  source = "Git Bash";
                };
              };

              # Profiles - Linux
              "terminal.integrated.profiles.linux" = {
                "zsh" = {
                  path = "zsh";
                  args = [ "-l" ];
                };
                "zellij" = {
                  path = "zellij";
                  args = [
                    "attach"
                    "--create"
                    "dev"
                  ];
                  icon = "terminal-tmux";
                };
              };

              # Appearance
              "terminal.integrated.cursorBlinking" = true;
              "terminal.integrated.cursorStyle" = "underline";
              "terminal.integrated.gpuAcceleration" = "off";
              "terminal.integrated.defaultProfile.linux" = "zsh";
            };

            # Fonts
            fonts = {
              "editor.fontFamily" = "Maple Mono, Maple Mono NF, Sarasa Mono SC, LXGW WenKai Mono, monospace";
              "editor.fontLigatures" = "discretionary-lig-values";
              "editor.fontSize" = 17;
              "editor.fontWeight" = "normal";
              "editor.codeLensFontFamily" = "Maple Mono, Sarasa Mono SC, monospace";
              "terminal.integrated.fontSize" = 16;
              "debug.console.fontFamily" = "Maple Mono NF, Sarasa Mono SC, monospace";
              "markdown.preview.fontFamily" = "Inter, Sarasa Mono SC";
              "scm.inputFontFamily" = "editor";
              "chat.fontSize" = 15;
            };

            # Language Formatters
            languageFormatters = {
              "[cpp]" = {
                "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
              };
              "[c]" = {
                "editor.defaultFormatter" = "llvm-vs-code-extensions.vscode-clangd";
              };
              "[javascript]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[typescript]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[typescriptreact]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[vue]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[html]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[css]" = {
                "editor.defaultFormatter" = "esbenp.prettier-vscode";
              };
              "[json]" = {
                "editor.defaultFormatter" = "vscode.json-language-features";
              };
              "[jsonc]" = {
                "editor.defaultFormatter" = "vscode.json-language-features";
              };
              "[python]" = {
                "editor.formatOnType" = true;
                "editor.defaultFormatter" = "eeyore.yapf";
              };
              "[scala]" = {
                "editor.defaultFormatter" = "scalameta.metals";
                "editor.formatOnSaveMode" = "file";
              };
              "[markdown]" = {
                "editor.defaultFormatter" = "DavidAnson.vscode-markdownlint";
              };
              "[nix]" = {
                "editor.insertSpaces" = true;
                "editor.tabSize" = 2;
                "editor.formatOnSaveMode" = "file";
                "editor.defaultFormatter" = "jnoortheen.nix-ide";
              };
              "[makefile]" = {
                "editor.detectIndentation" = false;
                "editor.insertSpaces" = false;
              };
              "[yaml]" = {
                "editor.defaultFormatter" = "redhat.vscode-yaml";
              };
              "[dockercompose]" = {
                "editor.insertSpaces" = true;
                "editor.tabSize" = 2;
                "editor.autoIndent" = "advanced";
                "editor.quickSuggestions" = {
                  other = true;
                  comments = false;
                  strings = true;
                };
                "editor.defaultFormatter" = "redhat.vscode-yaml";
              };
              "[github-actions-workflow]" = {
                "editor.defaultFormatter" = "redhat.vscode-yaml";
              };
              "[ocaml]" = {
                "editor.tabSize" = 2;
              };
              "[ocaml.interface]" = {
                "editor.tabSize" = 2;
              };
              "[typst]" = {
                "editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?";
              };
              "[typst-code]" = {
                "editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?";
              };
            };

            # Editor
            editor = {
              # Cursor & Display
              "editor.cursorStyle" = "underline";
              "editor.cursorBlinking" = "smooth";
              "editor.cursorSurroundingLines" = 64;
              "editor.lineNumbers" = "relative";
              "editor.renderWhitespace" = "boundary";
              "editor.renderControlCharacters" = true;
              "editor.unicodeHighlight.nonBasicASCII" = false;

              # Formatting
              "editor.formatOnType" = true;
              "editor.formatOnPaste" = true;
              "editor.formatOnSave" = true;
              "editor.formatOnSaveMode" = "modificationsIfAvailable";
              "editor.codeActionsOnSave" = {
                "source.fixAll.eslint" = "never";
              };

              # Word Wrap
              "editor.wordWrap" = "on";
              "editor.wordWrapColumn" = 120;

              # Suggestions
              "editor.suggestSelection" = "first";
              "editor.acceptSuggestionOnCommitCharacter" = false;
              "editor.acceptSuggestionOnEnter" = "off";
              "editor.inlineSuggest.enabled" = true;
              "editor.suggest.preview" = true;
              "editor.tabCompletion" = "on";

              # Features
              "editor.stickyScroll.enabled" = true;
              "editor.foldingStrategy" = "indentation";
              "editor.inlayHints.enabled" = "on";
              "editor.accessibilitySupport" = "off";
            };

            # Files
            files = {
              # Associations
              "files.associations" = {
                "*.vue" = "vue";
                "*.ejs" = "ejs";
                "*.mhtml" = "html";
                "Kconfig" = "plaintext";
                "*.svh" = "systemverilog";
              };

              # Exclusions
              "files.exclude" = {
                "**/.classpath" = true;
                "**/.project" = true;
                "**/.settings" = true;
                "**/.factorypath" = true;
              };
              "files.watcherExclude" = {
                "**/.bloop" = true;
                "**/.metals" = true;
                "**/.ammonite" = true;
              };

              # Misc
              "files.insertFinalNewline" = true;
            };

            # Extensions & Tools
            tools = {
              # Extensions
              "extensions.autoUpdate" = true;
              "extensions.ignoreRecommendations" = true;
              "extensions.experimental.affinity" = {
                "asvetliakov.vscode-neovim" = 1;
              };

              # Neovim
              "vscode-neovim.NVIM_APPNAME" = "nvim-vscode";
              "vscode-neovim.compositeKeys" = {
                "jk" = {
                  command = "vscode-neovim.lua";
                  args = [
                    [
                      "local code = require('vscode-neovim')"
                      "code.action('vscode-neovim.escape')"
                      "code.action('workbench.action.files.save')"
                    ]
                  ];
                };
              };

              # Git
              "git.enableSmartCommit" = true;
              "git.autofetch" = true;
              "git.confirmSync" = false;
              "git.alwaysSignOff" = true;
              "git.enableCommitSigning" = true;
              "git.openRepositoryInParentFolders" = "always";
              "git.ignoreRebaseWarning" = true;

              # GitLens
              "gitlens.defaultDateLocale" = null;
              "gitlens.defaultDateFormat" = "YYYY/MM/DD H:mm";
              "gitlens.defaultTimeFormat" = "H:mm";
              "gitlens.defaultDateShortFormat" = "YYYY/MM/DD";
              "gitlens.hovers.currentLine.over" = "line";
              "gitlens.ai.model" = "vscode";
              "gitlens.ai.gitkraken.model" = "gemini:gemini-2.0-flash";
              "gitlens.ai.vscode.model" = "copilot:gpt-4.1";

              # GitHub
              "githubPullRequests.pullBranch" = "never";

              # GitHub Copilot
              "github.copilot.enable" = {
                "*" = true;
                plaintext = false;
                markdown = false;
                scminput = false;
                yaml = false;
                dockerfile = true;
              };
              "github.copilot.nextEditSuggestions.enabled" = true;

              # Conventional Commits
              "conventionalCommits.lineBreak" = "\\n";
              "conventionalCommits.gitmoji" = false;
              "conventionalCommits.showEditor" = true;

              # GPG
              "gpgIndicator.enablePassphraseCache" = true;

              # Error Lens
              "errorLens.enabled" = true;

              # Markdown
              "markdownlint.config" = {
                "MD013" = false;
                "MD030" = false;
                "MD033" = false;
                "MD036" = false;
                "MD041" = false;
                "MD042" = false;
              };

              # ESLint
              "eslint.validate" = [
                "javascript"
                "typescript"
                "vue"
                "html"
                "ejs"
              ];

              # Prettier
              "prettier.bracketSameLine" = true;
              "prettier.tabWidth" = 4;

              # Live Server
              "liveServer.settings.donotVerifyTags" = true;
              "liveServer.settings.donotShowInfoMsg" = true;

              # Spell Checker
              "cSpell.enabledFileTypes" = {
                "*" = false;
              };
            };

            # Language-Specific Settings
            languages = {
              # Python
              "python.languageServer" = "Pylance";
              "python.analysis.inlayHints.variableTypes" = true;
              "python.analysis.inlayHints.pytestParameters" = true;
              "python.analysis.inlayHints.functionReturnTypes" = true;
              "yapf.args" = [
                "--style={based_on_style: google, column_limit: 128}"
              ];

              # Go
              "go.lintTool" = "staticcheck";
              "go.delveConfig" = {
                "dlvLoadConfig" = {
                  followPointers = true;
                  maxVariableRecurse = 1;
                  maxStringLen = 64;
                  maxArrayValues = 64;
                  maxStructFields = -1;
                };
                apiVersion = 2;
                showGlobalVariables = true;
              };
              "go.formatTool" = "goformat";
              "go.useLanguageServer" = true;
              "go.inlayHints.assignVariableTypes" = true;
              "go.inlayHints.constantValues" = true;
              "go.inlayHints.parameterNames" = true;
              "go.inlayHints.functionTypeParameters" = true;
              "go.inlayHints.rangeVariableTypes" = true;

              # JavaScript/TypeScript
              "js/ts.implicitProjectConfig.experimentalDecorators" = true;
              "javascript.format.semicolons" = "insert";
              "javascript.preferences.quoteStyle" = "double";
              "javascript.preferences.importModuleSpecifier" = "non-relative";
              "javascript.updateImportsOnFileMove.enabled" = "always";
              "javascript.inlayHints.functionLikeReturnTypes.enabled" = true;
              "javascript.inlayHints.propertyDeclarationTypes.enabled" = true;
              "javascript.inlayHints.variableTypes.enabled" = true;
              "javascript.suggest.paths" = false;
              "typescript.format.semicolons" = "insert";
              "typescript.preferences.quoteStyle" = "double";
              "typescript.preferences.importModuleSpecifier" = "non-relative";
              "typescript.inlayHints.parameterTypes.enabled" = true;
              "typescript.inlayHints.propertyDeclarationTypes.enabled" = true;
              "typescript.inlayHints.variableTypes.enabled" = true;
              "typescript.inlayHints.functionLikeReturnTypes.enabled" = true;
              "typescript.suggest.paths" = false;

              # Rust
              "rust-analyzer.inlayHints.bindingModeHints.enable" = true;
              "rust-analyzer.inlayHints.lifetimeElisionHints.enable" = "skip_trivial";
              "rust-analyzer.inlayHints.closureReturnTypeHints.enable" = "always";
              "rust-analyzer.cargo.features" = "all";

              # C/C++
              "clangd.fallbackFlags" = [ "" ];

              # Scala (Metals)
              "metals.inlayHints.inferredTypes.enable" = true;
              "metals.enableSemanticHighlighting" = true;
              "metals.inlayHints.typeParameters.enable" = true;
              "metals.inlayHints.hintsInPatternMatch.enable" = true;
              "metals.enableIndentOnPaste" = true;
              "metals.millScript" = "mill";

              # Nix
              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "nixd";
              "nix.serverSettings" = {
                "nixd" = {
                  "formatting" = {
                    command = [
                      "nix"
                      "fmt"
                      "--"
                      "--"
                    ];
                  };
                };
              };

              # Typst
              "tinymist.formatterMode" = "typstyle";

              # SCSS
              "scss.lint.duplicateProperties" = "error";
              "scss.lint.float" = "warning";
              "scss.lint.ieHack" = "warning";
              "liveSassCompile.settings.formats" = [
                {
                  format = "expanded";
                  extensionName = ".css";
                  savePath = null;
                }
              ];
            };

            # Workbench & UI
            workbench = {
              # Startup & Editor
              "workbench.startupEditor" = "newUntitledFile";
              "workbench.editorAssociations" = {
                "*.ipynb" = "jupyter-notebook";
                "git-rebase-todo" = "gitlens.rebase";
              };

              # Layout
              "workbench.sideBar.location" = "right";
              "workbench.navigationControl.enabled" = false;

              # Customizations
              "workbench.colorCustomizations" = {
                "terminal.background" = "#00000000";
              };
              "workbench.settings.applyToAllProfiles" = [
                "workbench.colorCustomizations"
              ];

              # Window
              "window.titleBarStyle" = "custom";

              # Explorer
              "explorer.confirmDelete" = false;
              "explorer.confirmDragAndDrop" = false;
            };

            # Misc
            misc = {
              # Debug
              "debug.allowBreakpointsEverywhere" = true;

              # Problems
              "problems.showCurrentInStatus" = true;

              # Notebook
              "notebook.cellToolbarLocation" = {
                default = "right";
                "jupyter-notebook" = "left";
              };

              # Remote
              "remote.autoForwardPortsFallback" = 0;

              # Security
              "security.workspace.trust.emptyWindow" = true;

              # Diff Editor
              "diffEditor.ignoreTrimWhitespace" = false;

              # NPM
              "npm.packageManager" = "pnpm";

              # Red Hat
              "redhat.telemetry.enabled" = false;

              # Settings Sync
              "settingsSync.ignoredSettings" = [ ];

              # CMake
              "cmake.pinnedCommands" = [
                "workbench.action.tasks.configureTaskRunner"
                "workbench.action.tasks.runTask"
              ];

              # Docker
              "docker.extension.enableComposeLanguageServer" = false;
            };
          in
          fonts
          // terminal
          // languageFormatters
          // editor
          // files
          // tools
          // languages
          // workbench
          // misc;

        keybindings = [
          # Suggestion Widget Navigation
          {
            key = "enter";
            command = "selectNextSuggestion";
            when = "editorTextFocus && suggestWidgetMultipleSuggestions && suggestWidgetVisible";
          }
          {
            key = "shift+enter";
            command = "selectPrevSuggestion";
            when = "editorTextFocus && suggestWidgetMultipleSuggestions && suggestWidgetVisible";
          }
          {
            key = "tab";
            command = "acceptSelectedSuggestion";
            when = "suggestWidgetHasFocusedSuggestion && suggestWidgetVisible && suggestionMakesTextEdit && textInputFocus";
          }

          # Terminal and Window Controls
          {
            key = "ctrl+`";
            command = "-workbench.action.terminal.toggleTerminal";
            when = "terminal.active";
          }
          {
            key = "ctrl+w";
            command = "-workbench.action.closeActiveEditor";
          }
          {
            key = "ctrl+w";
            command = "workbench.action.focusActiveEditorGroup";
            when = "!editorFocus";
          }

          # Move Lines in Insert Mode
          {
            key = "alt+k";
            command = "editor.action.moveLinesUpAction";
            when = "editorTextFocus && !editorReadonly && neovim.mode == insert";
          }
          {
            key = "alt+j";
            command = "editor.action.moveLinesDownAction";
            when = "editorTextFocus && !editorReadonly && neovim.mode == insert";
          }

          # Neovim Send Commands
          {
            key = "ctrl+n";
            command = "vscode-neovim.send";
            when = "editorTextFocus && neovim.mode != insert";
            args = "<c-n>";
          }
          {
            key = "ctrl+up";
            command = "vscode-neovim.send";
            when = "editorTextFocus && neovim.mode != insert";
            args = "<c-up>";
          }
          {
            key = "shift+up";
            command = "vscode-neovim.send";
            when = "editorTextFocus && neovim.mode != insert";
            args = "<S-up>";
          }
          {
            key = "shift+down";
            command = "vscode-neovim.send";
            when = "editorTextFocus && neovim.mode != insert";
            args = "<S-down>";
          }
          {
            key = "shift+left";
            command = "vscode-neovim.send";
            when = "editorTextFocus && neovim.mode != insert";
            args = "<S-left>";
          }
          {
            key = "shift+right";
            command = "vscode-neovim.send";
            when = "editorTextFocus && neovim.mode != insert";
            args = "<S-right>";
          }

          # Disable Conflicting Neovim Bindings
          {
            key = "ctrl+i";
            command = "-vscode-neovim.send";
            when = "editorTextFocus && neovim.ctrlKeysNormal.i && neovim.init && neovim.mode != 'insert' && editorLangId not in 'neovim.editorLangIdExclusions'";
          }
          {
            key = "ctrl+i";
            command = "-vscode-neovim.send";
            when = "editorTextFocus && neovim.ctrlKeysInsert.i && neovim.init && neovim.mode == 'insert' && editorLangId not in 'neovim.editorLangIdExclusions'";
          }
          {
            key = "ctrl+l";
            command = "-vscode-neovim.send";
            when = "editorTextFocus && neovim.ctrlKeysNormal.l && neovim.init && neovim.mode != 'insert' && editorLangId not in 'neovim.editorLangIdExclusions'";
          }
          {
            key = "ctrl+l";
            command = "-vscode-neovim.send";
            when = "editorTextFocus && neovim.ctrlKeysInsert.l && neovim.init && neovim.mode == 'insert' && editorLangId not in 'neovim.editorLangIdExclusions'";
          }
        ];

      };
    };

    services.wakatime.enable = true;
  };
}
