{ config, pkgs, lib, ... }:

with lib;

let
  # TODO: rewrite using declarative configuration
  hostnames = ["grindelwald.snabb.co" "interlaken.snabb.co" "davos.snabb.co"]
    ++ (map (i: "lugano-${toString i}.snabb.co") (range 1 4))
    ++ (map (i: "murren-${toString i}.snabb.co") (range 1 10))
    ++ (map (i: "build-${toString i}.snabb.co") (range 1 4));
  muninHosts = concatMapStringsSep "\n" (hostname: ''
    [${hostname}]
    address ssh://munin@${hostname} -i /etc/nix/id_buildfarm -W localhost:4949

  '') hostnames;
in {
  services.nginx.httpConfig = ''
      server {
        listen          80;
        server_name     munin.snabb.co;

        location /.well-known/acme-challenge {
          root /var/www/challenges;
        }
        location / {
          return 301 https://$host$request_uri;
        }
      }

      server {
        listen               443 ssl spdy;
        server_name          munin.snabb.co;
        keepalive_timeout    70;
        ssl                  on;
        ssl_certificate      /var/lib/acme/munin.snabb.co/fullchain.pem;
        ssl_certificate_key  /var/lib/acme/munin.snabb.co/key.pem;

        location / {
            root /var/www/munin;
        }
      }
  '';

    services.munin-cron = {
      enable = true;
      hosts = ''
        [eiger.snabb.co]
        address localhost
       
        ${muninHosts}
      '';
      extraGlobalConfig = ''
        contact.me.command mail -s "Munin notification for ''${var:host}" domen@dev.si
        contact.me.always_send warning critical
      '';
    };

  # Allow access to Hydra private ssh key /etc/nix/id_buildfarm
  users.extraUsers.munin.extraGroups = [ "hydra" ];


  security.acme.certs = {
    "munin.snabb.co" = {
      email = "munin@snabb.co";
      user = "nginx";
      group = "nginx";
      webroot = "/var/www/challenges";
      postRun = "systemctl reload nginx.service";
    };
  };
}
