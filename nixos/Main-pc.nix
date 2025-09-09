{
  config,
  lib,
  pkgs,
  ...
}:

{
  services = {
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
