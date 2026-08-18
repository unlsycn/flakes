{ config, ... }:
{
  # GitHub webhook ingress for the local buildbot master; only the change hook
  # path is exposed publicly, the full UI stays on the mesh (see buildbot-master).
  mesh.services.webhook = {
    exposure.public = true;
    publicDomain = "webhook.unlsycn.com";
    locations."/change_hook/github".proxyPass =
      "http://127.0.0.1:${toString config.services.buildbot-master.port}";
  };
}
