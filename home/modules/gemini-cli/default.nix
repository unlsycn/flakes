{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.gemini-cli;
in
{

  config = lib.mkIf cfg.enable {
    programs.gemini-cli = {
      package = pkgs.gemini-cli.overrideAttrs (old: rec {
        version = "0.27.0";
        src = pkgs.fetchFromGitHub {
          owner = "google-gemini";
          repo = "gemini-cli";
          tag = "v${version}";
          hash = "sha256-ptx+aBlw6Koyv5NWZNXOunPJfedv1JwprG1SaRLwrGg=";
        };
        npmDeps = pkgs.fetchNpmDeps {
          inherit src;
          hash = "sha256-0bS3yl5EG2KyfBrw8SO1BfKwxb1f2LVsudeaQTb5/DQ=";
        };
      });
      commands = {
        "git/commit" = {
          prompt = "Please analyze the staged changes and recent git history to generate a commit message";
          description = "Generate a commit message for the staged changes";
        };
      };
      settings = {
        experimental = {
          enableAgents = true;
          skills = true;
          useOSC52Paste = true;
          plan = true;
        };
        general = {
          disableAutoUpdate = true;
          enablePromptCompletion = true;
          previewFeatures = true;
          vimMode = true;
          enableAutoUpdate = false;
        };
        output = {
          format = "text";
        };
        security = {
          auth = {
            selectedType = "oauth-personal";
          };
          enablePermanentToolApproval = true;
        };
        ui = {
          hideBanner = true;
          showCitations = true;
          showModelInfoInChat = true;
        };
        tools = {
          shell = {
            enableInteractiveShell = true;
            showColor = true;
            pager = lib.getExe config.programs.bat.package;
          };
        };
      };
    };

    home.persistence."/persist".directories = [
      ".gemini"
    ];
  };
}
