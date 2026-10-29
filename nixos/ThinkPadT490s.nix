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
      cert = config.sops.secrets."syncthing/ThinkPadT490s/cert.pem".path;
      key = config.sops.secrets."syncthing/ThinkPadT490s/key.pem".path;
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
  sops.secrets = {
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
    "yggdrasil_key" = {
      format = "binary";
      sopsFile = ../yggdrasil/ThinkPadT490s/key.pem;
    };
    "borg/ThinkPadT490s/home" = { };
  };

  systemd.sleep.settings.Sleep = {

    AllowSuspend = "yes";
    #AllowHibernation="no";
    #AllowHybridSleep="no";
    #AllowSuspendThenHibernate="no";
  };
}
