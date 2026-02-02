{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.gemini-cli;
in
{

  config = lib.mkIf cfg.enable {
    programs.gemini-cli = {
      commands = {
        "git/commit" = {
          prompt = "Please analyze the staged changes and recent git history to generate a commit message";
          description = "Generate a commit message for the staged changes";
        };
      };
      settings = {
        security = {
          auth = {
            selectedType = "oauth-personal";
          };
        };
        general = {
          previewFeatures = true;
          vimMode = true;
          disableAutoUpdate = true;
          enablePromptCompletion = true;
        };
        ui = {
          hideBanner = true;
          showCitations = true;
          showModelInfoInChat = true;
        };
        experimental = {
          useOSC52Paste = true;
          skills = true;
        };
        output = {
          format = "text";
        };
      };
    };

    home.persistence."/persist".directories = [
      ".gemini"
    ];
  };
}
