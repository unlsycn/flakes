{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.gemini-cli;
  llmCfg = config.programs.llm-cli;
in
{
  config = lib.mkIf cfg.enable {
    programs.gemini-cli = {
      commands =
        llmCfg.commands
        |> lib.mapAttrs (
          _: cmd: {
            inherit (cmd) prompt description;
          }
        );
      settings = {
        context.fileName = llmCfg.projectInstructions;
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
