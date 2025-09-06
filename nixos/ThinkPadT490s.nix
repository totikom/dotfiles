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
        };
      };
    };

    yggdrasil = {
      enable = true;
      configFile = config.sops.secrets.yggdrasil_config.path;
      settings = {
        Peers = [
          "tcp://srv.itrus.su:7991"
          "tcp://ip4.01.msk.ru.dioni.su:9002"
          "quic://ip4.01.msk.ru.dioni.su:9002"
          "tcp://s-mow-0.sergeysedoy97.ru:65533"
          "tcp://s-mow-1.sergeysedoy97.ru:65533"
          "tcp://x-mow-1.sergeysedoy97.ru:65533"
          "tls://[2a09:5302:ffff::992]:443"
        ];
      };
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

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
  '';
  #AllowHibernation=no
  #AllowHybridSleep=no
  #AllowSuspendThenHibernate=no
}

