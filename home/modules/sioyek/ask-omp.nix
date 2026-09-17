{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.sioyek;

  readerDir = "${config.home.homeDirectory}/.local/share/sioyek/omp-reader";

  ask-omp = pkgs.writeShellScriptBin "ask-omp" ''
    set -u

    file=$1
    page=$((10#$2 + 1))
    text=$3
    question=''${4:-将上述选中段落翻译成中文。保留专业术语原文，必要时给出简短解释。}

    mkdir -p ${readerDir}/sessions ${readerDir}/answers
    cd ${readerDir}

    model=smol

    msg="我在阅读 PDF 论文，需要你的帮助。

    文件：$file
    页码：第 $page 页（物理页码，从 1 开始）
    选中段落：
    \"\"\"
    $text
    \"\"\"

    $question

    （如需更多上下文，可以用 read 工具阅读上述文件的相邻页面）"

    out=$(mktemp "answers/$(date +%Y%m%d-%H%M%S)-XXXXXX.md")

    (
      (
        flock -x 9

        cont=()
        find sessions -name '*.jsonl' -print -quit 2>/dev/null | grep -q . && cont=(--continue)

        {
          printf '# %s\n\n' "$question"
          printf '> `%s` · 第 %s 页\n\n' "$file" "$page"
          if answer=$(${lib.getExe' config.programs.omp.finalPackage "omp"} --session-dir sessions --model "$model" "''${cont[@]}" -p "$msg" 2>>error.log) && [ -n "$answer" ]; then
            printf '%s\n' "$answer"
          else
            printf 'omp 未返回结果（鉴权/网络/服务问题），详见 error.log。\n'
          fi
        } | tee -a log.md >"$out"

        if [ -f error.log ] && [ "$(stat -c%s error.log)" -gt 5242880 ]; then
          tail -c 1048576 error.log >error.log.tmp && mv error.log.tmp error.log
        fi
      ) 9>.lock

      ${lib.getExe' pkgs.ghostty "ghostty"} --title=sioyek-reader -e ${lib.getExe pkgs.glow} -p "$out"
    ) >>error.log 2>&1 &
  '';
in
with lib;
{
  options.programs.sioyek.askOmp.enable = mkOption {
    default = config.programs.omp.enable;
    type = types.bool;
    description = "Whether to enable the omp reading-companion bridge (T key: translate/ask via a persistent omp session)";
  };

  config = mkIf (cfg.enable && cfg.askOmp.enable) {
    programs.sioyek = {
      config.new_command = "_ask_omp ${ask-omp}/bin/ask-omp \"%{file_path}\" \"%{page_number}\" \"%{selected_text}\" \"%{command_text}\"";
      bindings._ask_omp = "T";
    };

    home.packages = [ ask-omp ];

    wayland.windowManager.hyprland.windowRules = mkIf config.wayland.windowManager.hyprland.enable {
      sioyek-reader = {
        match.title = "sioyek-reader";
        float = true;
        center = true;
        size = "70% 80%";
      };
    };
  };
}
