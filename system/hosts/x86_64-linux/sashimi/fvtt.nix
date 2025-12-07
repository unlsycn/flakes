{ inputs', ... }:
{
  services.foundryvtt = {
    enable = true;
    package = inputs'.foundryvtt.packages.foundryvtt_13;
    hostName = "fvtt.unlsycn.com";
    port = 1501;
    minifyStaticFiles = true;
    upnp = false;
    language = "cn.foundry_chn";
  };
}
