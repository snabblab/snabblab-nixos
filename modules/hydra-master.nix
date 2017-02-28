{ config, pkgs, lib, ... }:

with lib;

let
  commonBuildMachineOpt = {
    speedFactor = 1;
    sshKey = "/etc/nix/id_buildfarm";
    sshUser = "root";
    system = "x86_64-linux";
    supportedFeatures = [ "kvm" "nixos-test" ];
  };
in {
  environment.etc = lib.singleton {
    target = "nix/id_buildfarm";
    source = ../secrets/id_buildfarm;
    uid = config.ids.uids.hydra;
    gid = config.ids.gids.hydra;
    mode = "0440";
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [
      (commonBuildMachineOpt // {
        hostName = "lugano-2.snabb.co";
        maxJobs = 1;
        mandatoryFeatures = [ "lugano" ];
      })
      (commonBuildMachineOpt // {
        hostName = "lugano-4.snabb.co";
        maxJobs = 1;
        mandatoryFeatures = [ "lugano" ];
      })
      (commonBuildMachineOpt // {
        hostName = "snabb2.igalia.com";
        maxJobs = 1;
        mandatoryFeatures = [ "igalia" ];
      })
      (commonBuildMachineOpt // {
        hostName = "grindelwald.snabb.co";
        maxJobs = 1;
        mandatoryFeatures = [ "openstack" ];
      })
      (commonBuildMachineOpt // {
        hostName = "localhost";
        maxJobs = 2;
        mandatoryFeatures = [ "local" ];
      })
    ] ++ (map (i:
      (commonBuildMachineOpt // {
        hostName = "build-${toString i}.snabb.co";
        maxJobs = 8;
      })
    ) (range 1 4))
    ++ (map (i:
      (commonBuildMachineOpt // {
        hostName = "murren-${toString i}.snabb.co";
        maxJobs = 1;
        supportedFeatures = [ "murren" ] ++ commonBuildMachineOpt.supportedFeatures;
      })
    ) (range 1 10));
    extraOptions = "auto-optimise-store = true";
  };


  # let's auto-accept fingerprints on first connection
  programs.ssh.extraConfig = ''
    StrictHostKeyChecking no
  '';

  services.hydra = {
    enable = true;
    hydraURL = "http://hydra.snabb.co";
    notificationSender = "hydra@hydra.snabb.co";
    port = 8080;
    # workaround https://github.com/NixOS/hydra/issues/297
    useSubstitutes = true;
    # max output is 4GB because of openstack image
    extraConfig = ''
      binary_cache_secret_key_file = /etc/nix/hydra.snabb.co-1/secret
      max_output_size = 4294967296
    '';
    logo = (pkgs.fetchurl {
      url    = "https://avatars2.githubusercontent.com/u/1913310?s=40";
      sha256 = "087zlf6r57zgz05q875bjs0ljmvxxla4nbr64gxccxac222vw77w";
    });
  };

  # this is most important to us, so prioritize cpu right after the kernel
  systemd.services.hydra-evaluator.serviceConfig.Nice = -19;

  services.postgresql = {
    package = pkgs.postgresql94;
    dataDir = "/var/db/postgresql-${config.services.postgresql.package.psqlSchema}";
  };

  systemd.services.hydra-manual-setup = {
    description = "Create Keys for Hydra";
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    wantedBy = [ "multi-user.target" ];
    requires = [ "hydra-init.service" ];
    after = [ "hydra-init.service" ];
    environment = config.systemd.services.hydra-init.environment;
    script = ''
      if [ ! -e ~hydra/.setup-is-complete ]; then
        # create signing keys
        /run/current-system/sw/bin/install -d -m 551 /etc/nix/hydra.snabb.co-1
        /run/current-system/sw/bin/nix-store --generate-binary-cache-key hydra.snabb.co-1 /etc/nix/hydra.snabb.co-1/secret /etc/nix/hydra.snabb.co-1/public
        /run/current-system/sw/bin/chown -R hydra:hydra /etc/nix/hydra.snabb.co-1
        /run/current-system/sw/bin/chmod 440 /etc/nix/hydra.snabb.co-1/secret
        /run/current-system/sw/bin/chmod 444 /etc/nix/hydra.snabb.co-1/public
        # done
        touch ~hydra/.setup-is-complete
      fi
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme.certs = {
    "hydra.snabb.co" = {
      email = "hydra@snabb.co";
      user = "nginx";
      group = "nginx";
      webroot = "/var/www/challenges";
      postRun = "systemctl reload nginx.service";
    };
  };

  services.nginx = {
    enable = true;
    httpConfig = ''
      server_names_hash_bucket_size 64;

      keepalive_timeout   70;
      gzip            on;
      gzip_min_length 1000;
      gzip_proxied    expired no-cache no-store private auth;
      gzip_types      text/plain application/xml application/javascript application/x-javascript text/javascript text/xml text/css;

      server {
        server_name _;
        listen 80;
        listen [::]:80;
        location /.well-known/acme-challenge {
          root /var/www/challenges;
        }
        location / {
          return 301 https://$host$request_uri;
        }
      }

      # TODO: SSL hardening

      server {
        listen 443 ssl spdy;
        server_name hydra.snabb.co;

        ssl_certificate /var/lib/acme/hydra.snabb.co/fullchain.pem;
        ssl_certificate_key /var/lib/acme/hydra.snabb.co/key.pem;

        location / {
          proxy_pass http://127.0.0.1:8080;
          proxy_set_header Host $http_host;
          proxy_set_header REMOTE_ADDR $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto https;
        }
      }
    '';
  };
}
