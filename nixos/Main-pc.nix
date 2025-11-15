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
      openDefaultPorts = true;
      overrideFolders = true;
      user = "eugene";
      dataDir = "/home/eugene";
      overrideDevices = true;
      cert = config.sops.secrets."syncthing/Main-pc/cert.pem".path;
      key = config.sops.secrets."syncthing/Main-pc/key.pem".path;
      extraFlags = [ "--no-default-folder" ]; # Don't create default ~/Sync folder
      settings = {
        devices = {
          "Redmi K80 Pro" = {
            id = "7KDCBRR-3VGLY3C-QZ2T6TL-2FC76U6-3AEEEXQ-JHTYWCP-D6LFWBU-7OTWCAR";
          };
          "ThinkPad" = {
            id = "I3NH3E2-RTOWUQI-RYIRCVC-WOHX2GJ-V6TOFTD-BGOWB22-B5E67VQ-77DHHQA";
          };
          "ThinkPadT490s" = {
            id = "FMJ3P2U-2FEYA7S-TGSEAU5-EKLDGYS-RJ3VJ2O-RLMUM27-OJYDAYK-QF5WNQG";
          };
        };
        folders = {
          "tab.digital" = {
            label = "tab.digital";
            id = "ego4c-ckkzv";
            path = "~/Documents/tab.digital";
            devices = [
              "Redmi K80 Pro"
              "ThinkPad"
              "ThinkPadT490s"
            ];
          };
          "Documents" = {
            id = "fp5rw-7j1x3";
            path = "~/Documents/Phone";
            devices = [
              "Redmi K80 Pro"
              "ThinkPad"
              "ThinkPadT490s"
            ];
          };
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
          "Main-pc videos" = {
            id = "zczny-swe3w";
            path = "~/Videos/Synced";
            devices = [
              "ThinkPadT490s"
            ];
          };
          "Main-pc junk" = {
            id = "tshjv-zsprm";
            path = "~/.junk/Synced";
            devices = [
              "ThinkPadT490s"
            ];
          };
        };
      };
    };
    yggdrasil = {
      enable = true;
      configFile = config.sops.secrets."yggdrasil/Main-pc/conf".path;
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
