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
      secrets_from_default_file = {
        "borg/ThinkPadT490s/home" = { };
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

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
  '';
  #AllowHibernation=no
  #AllowHybridSleep=no
  #AllowSuspendThenHibernate=no
}
