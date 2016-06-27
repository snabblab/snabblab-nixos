{ config, pkgs, lib, ... }:
with lib;
with pkgs;

let
  snabb_doc = writeScript "snabb_doc.sh" (readFile (fetchurl {
     url = "https://raw.githubusercontent.com/eugeneia/snabb/cca676efb3c2603a53eaff7d1aba0683a5fb3738/src/scripts/snabb_doc.sh";
     sha256 = "6d9e3f397a249a0b2182358d6389504764c3c594ab6d270d2f901d0bcafcd200";
  }));
in {
  options = {

    services.snabb_doc = {

      credentials = lib.mkOption {
        type = types.str;
        default = "";
        description = ''
          GitHub credentials for SnabbDoc instance.
        '';
        example = ''
          username:password
        '';
      };

      dir = lib.mkOption {
        type = types.str;
        default = "/tmp/snabb_doc";
        description = ''
          Target GitHub repository for SnabbDoc instance.
        '';
      };

      repo = lib.mkOption {
        type = types.str;
        default = "SnabbCo/snabb";
        description = ''
          Target GitHub repository for SnabbDoc instance.
        '';
      };


      docrepo = lib.mkOption {
        type = types.str;
        default = "snabbco/snabbco.github.com";
        description = ''
          GitHub pages repository to host documentation.
        '';
      };

      url = lib.mkOption {
        type = types.str;
        default = "https://snabbco.github.com";
        description = ''
          URL of documentation site.
        '';
      };

      period = lib.mkOption {
        type = types.str;
        default = "*/30 * * * *";
        description = ''
          This option defines (in the format used by cron) when the
          SnabbDoc runs. The default is every minute.
        '';
      };

    };

  };

  config = {

    systemd.services.snabb_doc =
      { description = "Run SnabbDoc";
        path  = [(pkgs.buildEnv {
          name = "snabb_doc-env";
          paths = [ bash curl git jq gnumake findutils gcc ditaa pandoc coreutils busybox
                    (texlive.combine {
                      inherit (texlive) scheme-small luatex luatexbase sectsty titlesec cprotect bigfoot titling droid;
                  })];
          ignoreCollisions = true;
        })];
        script =
          ''
            export GITHUB_CREDENTIALS=${config.services.snabb_doc.credentials}
            export SNABBDOCDIR=${config.services.snabb_doc.dir}
            export REPO=${config.services.snabb_doc.repo}
            export DOCREPO=${config.services.snabb_doc.docrepo}
            export DOCURL=${config.services.snabb_doc.url}

            exec flock -x -n /var/lock/snabb_doc ${snabb_doc}
          '';
        environment.SSL_CERT_FILE = config.environment.sessionVariables.SSL_CERT_FILE;
      };

    services.cron.systemCronJobs =
      [ "${config.services.snabb_doc.period} root ${config.systemd.package}/bin/systemctl start snabb_doc.service" ];

  };
}
