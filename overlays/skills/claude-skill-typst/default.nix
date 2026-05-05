{
  fetchFromGitHub,
  ...
}:
let
  src = fetchFromGitHub {
    owner = "lucifer1004";
    repo = "claude-skill-typst";
    rev = "6628cbf7205fe5059209875f69d80c962064b360";
    hash = "sha256-hyLp3/ivDaEsdrPh2yMcBZqzeC0HNddLrabOZrRvHhM=";
  };
in
builtins.path {
  name = "typst";
  path = src + "/skills/typst";
}
