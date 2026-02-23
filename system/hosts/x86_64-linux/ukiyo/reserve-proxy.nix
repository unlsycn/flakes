{ config, lib, ... }:
{
  mesh.services = {
    webhook = {
      expose.public = true;
      publicDomain = "webhook.unlsycn.com";
      locations = lib.genAttrs [ "/change_hook/github" ] (
        path:
        let
          host = "build.${config.mesh.nebula.domain}";
        in
        {
          proxyPass = "https://${host}";

          extraConfig = ''
            proxy_set_header Host ${host};
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            proxy_read_timeout 60s;
            proxy_connect_timeout 10s;
          '';
        }
      );
      extraConfig = ''
        proxy_headers_hash_max_size 1024;
        proxy_headers_hash_bucket_size 128;
      '';
    };
  };
  services.nginx.recommendedProxySettings = false;
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
