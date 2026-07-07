{ lib, pkgs }:
with lib;
let
  jq = getExe pkgs.jq;
  yj = getExe pkgs.yj;

  codecs = {
    json = {
      readExisting = "${jq} . \"$targetPath\" 2>/dev/null";
      readStatic = "${jq} . \"$sourcePath\"";
      write = "${jq} .";
    };

    toml = {
      readExisting = "${yj} -tj < \"$targetPath\" 2>/dev/null";
      readStatic = "${yj} -tj < \"$sourcePath\"";
      write = "${yj} -jt";
    };
  };
in
{
  config,
  targetPath,
  homeFilePath,
  format,
  mode ? "0644",
  after ? [ "linkGeneration" ],
}:
let
  codec =
    if hasAttr format codecs then
      codecs.${format}
    else
      throw "Unsupported mutable generated file format: ${format}";
in
{
  activation = hm.dag.entryAfter after ''
    (
      targetPath=${escapeShellArg targetPath}
      sourcePath=${escapeShellArg (toString config.home.file.${homeFilePath}.source)}
      expectedMode=${escapeShellArg (if hasPrefix "0" mode then removePrefix "0" mode else mode)}
      tmp="$(mktemp)"
      trap 'rm -f "$tmp"' EXIT

      run mkdir -p $VERBOSE_ARG "$(dirname -- "$targetPath")"

      dynamic="$(
        if [ -e "$targetPath" ] || [ -L "$targetPath" ]; then
          ${codec.readExisting} || printf '%s\n' '{}'
        else
          printf '%s\n' '{}'
        fi
      )"
      static="$(${codec.readStatic})"
      merged="$(${jq} -n '$dynamic * $static' --argjson dynamic "$dynamic" --argjson static "$static")"

      printf '%s\n' "$merged" | ${codec.write} > "$tmp"

      replaceTarget=false
      if [ -L "$targetPath" ]; then
        run rm -f $VERBOSE_ARG "$targetPath"
        replaceTarget=true
      elif [ -e "$targetPath" ] && [ ! -f "$targetPath" ]; then
        echo "Refusing to replace non-regular file: $targetPath" >&2
        exit 1
      fi

      modeMatches=false
      if [ -e "$targetPath" ] && [ "$(stat -c '%a' "$targetPath")" = "$expectedMode" ]; then
        modeMatches=true
      fi

      if [ "$replaceTarget" = true ] || [ "$modeMatches" != true ] || [ ! -e "$targetPath" ] || ! cmp --quiet "$tmp" "$targetPath"; then
        run install -m ${escapeShellArg mode} $VERBOSE_ARG "$tmp" "$targetPath"
      fi
    )
  '';

  homeFile.${homeFilePath}.enable = mkForce false;
}
