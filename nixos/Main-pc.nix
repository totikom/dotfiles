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
    yggdrasil = {
      enable = true;
      configFile = config.sops.secrets."yggdrasil/Main-pc/conf".path;
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
      enable = true;
      dataDir = "/mnt/Media/ipfs";
      settings.Addresses.API = "http://127.0.0.1:5001";
    };
  };
  systemd.services.transmission.serviceConfig = {
    BindPaths = [
      "${config.users.users.eugene.home}/Videos"
      "${config.users.users.eugene.home}/Books"
      "${config.users.users.eugene.home}/Music"
      "/mnt/Media"
    ];
    TimeoutSec = "5m";
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
        "yggdrasil/Main-pc/conf" = {
          format = "binary";
          sopsFile = ../yggdrasil/Main-pc/yggdrasil.conf;
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
}
