{ lib, ... }:
{
  home.persistence."/persist".enable = lib.mkDefault false;
}
