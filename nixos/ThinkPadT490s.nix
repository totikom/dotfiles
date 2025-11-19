{
  config,
  lib,
  pkgs,
  ...
}:

{
  services = {
    auto-cpufreq.enable = true;
    auto-cpufreq.settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };

    syncthing = {
      enable = true;
      openDefaultPorts = true;
      overrideFolders = true;
      user = "eugene";
      dataDir = "/home/eugene";
      overrideDevices = true;
      cert = config.sops.secrets."syncthing/ThinkPadT490s/cert.pem".path;
      key = config.sops.secrets."syncthing/ThinkPadT490s/key.pem".path;
      extraFlags = [ "--no-default-folder" ]; # Don't create default ~/Sync folder
      settings = {
        devices = {
          "Redmi K80 Pro" = {
            id = "7KDCBRR-3VGLY3C-QZ2T6TL-2FC76U6-3AEEEXQ-JHTYWCP-D6LFWBU-7OTWCAR";
          };
          "ThinkPad" = {
            id = "I3NH3E2-RTOWUQI-RYIRCVC-WOHX2GJ-V6TOFTD-BGOWB22-B5E67VQ-77DHHQA";
          };
          "Main-pc" = {
            id = "34EFVRV-MRV5SDY-TGYZAM2-J6OJECF-PBMEBV2-TX2CUKN-RACKTV2-CDUK5Q4";
          };
        };
        folders = {
          "tab.digital" = {
            label = "tab.digital";
            id = "ego4c-ckkzv";
            path = "~/Documents/tab.digital";
            devices = [
              "Main-pc"
              "Redmi K80 Pro"
              "ThinkPad"
            ];
          };
          "Documents" = {
            id = "fp5rw-7j1x3";
            path = "~/Documents/Phone";
            devices = [
              "Main-pc"
              "Redmi K80 Pro"
              "ThinkPad"
            ];
          };
          "Main-pc videos" = {
            id = "zczny-swe3w";
            path = "~/Videos/Synced";
            devices = [
              "Main-pc"
            ];
          };
          "Main-pc junk" = {
            id = "tshjv-zsprm";
            path = "~/.junk/Synced";
            devices = [
              "Main-pc"
            ];
          };
        };
      };
    };

    yggdrasil = {
      enable = true;
      configFile = config.sops.secrets."yggdrasil/ThinkPadT490s/conf".path;
    };

    snapper = {
      snapshotInterval = "hourly";
      persistentTimer = true;
      cleanupInterval = "1d";
      configs = {
        home = {
          FSTYPE = "btrfs";
          SUBVOLUME = "/home";
          SPACE_LIMIT = "0.5";
          FREE_LIMIT = "0.2";
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
        "syncthing/ThinkPadT490s/cert.pem" = {
          format = "binary";
          owner = config.users.users.eugene.name;
          mode = "0600";
          sopsFile = ../syncthing/ThinkPadT490s/cert.pem;
        };
        "syncthing/ThinkPadT490s/key.pem" = {
          format = "binary";
          owner = config.users.users.eugene.name;
          mode = "0600";
          sopsFile = ../syncthing/ThinkPadT490s/key.pem;
        };
        "yggdrasil/ThinkPadT490s/conf" = {
          format = "binary";
          sopsFile = ../yggdrasil/ThinkPadT490s/yggdrasil.conf;
        };
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
      secrets = hand_written_secrets // generated_secrets;
    };

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
  '';
  #AllowHibernation=no
  #AllowHybridSleep=no
  #AllowSuspendThenHibernate=no
}
