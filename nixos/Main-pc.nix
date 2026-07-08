{
  config,
  lib,
  pkgs,
  ...
}:

{
  services = {
    syncthing = {
      enable = true;
      cert = config.sops.secrets."syncthing/Main-pc/cert.pem".path;
      key = config.sops.secrets."syncthing/Main-pc/key.pem".path;
      settings = {
        folders = {
          "Phone Photos" = {
            id = "0yno0-m0zuz";
            path = "~/Pictures/Phone";
            devices = [
              "Redmi K80 Pro"
            ];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "14";
            };
          };
          "Music" = {
            id = "bxcjr-59xqc";
            path = "~/Music";
            devices = [
              "Redmi K80 Pro"
            ];
          };
        };
      };
    };
    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      user = "eugene";
      openFirewall = true;
      settings = {
        download-dir = "${config.users.users.eugene.home}/.junk";
        download-queue-enabled = false;
        incomplete-dir-enabled = false;
        rename-partial-files = true;
        trash-original-torrent-files = true;
        watch-dir = "${config.users.users.eugene.home}/Downloads";
        watch-dir-enabled = true;
      };
    };
    kubo = {
      enable = false;
      dataDir = "/mnt/Media/ipfs";
      settings.Addresses.API = "http://127.0.0.1:5001";
    };
    snapper = {
      snapshotInterval = "daily";
      persistentTimer = true;
      cleanupInterval = "1d";
      configs = {
        home = {
          FSTYPE = "btrfs";
          SUBVOLUME = "/home";
          SPACE_LIMIT = "0.5";
          FREE_LIMIT = "0.1";
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_MIN_AGE = "1800";
          TIMELINE_LIMIT_HOURLY = "1";
          TIMELINE_LIMIT_DAILY = "7";
          TIMELINE_LIMIT_WEEKLY = "8";
          TIMELINE_LIMIT_MONTHLY = "4";
          TIMELINE_LIMIT_YEARLY = "0";
        };
        pictures = {
          FSTYPE = "btrfs";
          SUBVOLUME = "/home/eugene/Pictures";
          SPACE_LIMIT = "0.5";
          FREE_LIMIT = "0.01";
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_MIN_AGE = "1800";
          TIMELINE_LIMIT_HOURLY = "1";
          TIMELINE_LIMIT_DAILY = "7";
          TIMELINE_LIMIT_WEEKLY = "8";
          TIMELINE_LIMIT_MONTHLY = "4";
          TIMELINE_LIMIT_YEARLY = "0";
        };
      };
    };
    apcupsd = {
      enable = true;
      configText = ''
        UPSCABLE usb
        UPSTYPE usb
        ONBATTERYDELAY 6
        BATTERYLEVEL 5
        MINUTES 2
        TIMEOUT 0
        NISIP 127.0.0.1
        '';
    };
  };
  systemd.services = {
    transmission.serviceConfig = {
      BindPaths = [
        "${config.users.users.eugene.home}/Videos"
        "${config.users.users.eugene.home}/Books"
        "${config.users.users.eugene.home}/Music"
        "/mnt/Media"
      ];
      TimeoutSec = "5m";
    };
    freeleech = {
      description = "Move torrent files to download dir during freeleech";
      script = ''
        set -ux
        ${pkgs.coreutils}/bin/mv \
        ${config.users.users.eugene.home}/Downloads/Freeleech/* \
        ${config.users.users.eugene.home}/Downloads 
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "eugene";
      };
      startAt = "Sat *-*~01..07 0:05 Europe/Moscow";
    };
  };

  sops =
    let
      wifi_generator = name: value: {
        format = "binary";
        path = "/etc/NetworkManager/system-connections/${name}";
        restartUnits = [ "NetworkManager.service" ];
        sopsFile = ../wifis/${name};
      };
      generated_secrets = builtins.mapAttrs (wifi_generator) (builtins.readDir (../wifis));
      hand_written_secrets = {
        "syncthing/Main-pc/cert.pem" = {
          format = "binary";
          owner = config.users.users.eugene.name;
          mode = "0600";
          sopsFile = ../syncthing/Main-pc/cert.pem;
        };
        "syncthing/Main-pc/key.pem" = {
          format = "binary";
          owner = config.users.users.eugene.name;
          mode = "0600";
          sopsFile = ../syncthing/Main-pc/key.pem;
        };
        "yggdrasil_key" = {
          format = "binary";
          sopsFile = ../yggdrasil/Main-pc/key.pem;
        };
      };
      secrets_from_default_file = {
        "borg/Main-pc/home" = { };
        "borg/Main-pc/pictures" = { };
      };
    in
    {
      # This will add secrets.yml to the nix store
      # You can avoid this by adding a string to the full path instead, i.e.
      # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
      defaultSopsFile = ./secrets.json;

      # This will automatically import SSH keys as age keys
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

      # This is the actual specification of the secrets.
      secrets = hand_written_secrets // generated_secrets // secrets_from_default_file;
    };
}
