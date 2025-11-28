{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "encrypted_root";
                passwordFile = "/tmp/secret.key"; # Interactive
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress=zstd"
                      ];
                    };
                    "/unbacked_files" = {
                      mountpoint = "/home/.unbacked_files";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "16G";
                    };
                  };
                  mountpoint = "/mnt/root_subvol";
                };
              };
            };
          };
        };
      };
      media = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "encrypted_media";
                passwordFile = "/tmp/secret.key"; # Interactive
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    media_root = {
                      mountpoint = "/mnt/Media";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    ".junk" = {
                      mountpoint = "/home/eugene/.junk";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    Pictures = {
                      mountpoint = "/home/eugene/Pictures";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    Videos = {
                      mountpoint = "/home/eugene/Videos";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    Books = {
                      mountpoint = "/home/eugene/Books";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    Music = {
                      mountpoint = "/home/eugene/Music";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                  mountpoint = "/mnt/media_subvol";
                };
              };
            };
          };
        };
      };
    };
  };
}
