{ fetchFromGitHub, lib }:
let
  superpowersSrc = fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "8ea39819eed74fe2a0338e71789f06b30e953041";
    hash = "sha256-wmOArGgOahJK/mqzYJZW6qcUNaOB6yL57RQMe56S1uw=";
  };
  superpowersSkillsDir = superpowersSrc + "/skills";
in
superpowersSkillsDir
|> builtins.readDir
|> lib.filterAttrs (_: type: type == "directory")
|> lib.mapAttrs (skill: _: superpowersSkillsDir + "/${skill}")
