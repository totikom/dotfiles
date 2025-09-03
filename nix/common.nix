# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.fira-code
    font-awesome
  ];

  security.rtkit.enable = true;
  security.sudo = {
    enable = true;
    extraConfig = "Defaults insults,pwfeedback";
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.networkmanager}/bin/nmtui";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };

  # List services that you want to enable:
  services = {
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      desktopManager.xterm.enable = false;
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3lock # default i3 screen locker
        ];
      };

      # Configure keymap in X11
      xkb.layout = "us,ru";
      xkb.options = "grp:shift_caps_switch,grp_led:caps";
    };
    displayManager.defaultSession = "none+i3";

    pcscd.enable = true;
    # Enable sound.
    # hardware.pulseaudio.enable = true;
    # OR
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    mullvad-vpn.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };

    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      settings = {
        AllowUsers = [ "eugene" ];
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      ports = [ 55060 ];
    };

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
      cert = config.sops.secrets."syncthing/thinkpadt490s/cert.pem".path;
      key = config.sops.secrets."syncthing/thinkpadt490s/key.pem".path;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eugene = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    #openssh.authorizedKeys.keyFiles = [];
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed firs
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    htop
  ];

  programs = {
    zsh.enable = true;
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.nftables = {
    enable = true;
    tables = {
      # Allow yggdrasil to be routed outside of mullvad
      allowYggdrasil = {
        content = ''
          chain excludeOutgoing {
            type route hook output priority -1; policy accept;
            ip6 daddr 200::/7 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
          }
        '';
        family = "inet";
      };
    };
  };
  networking.firewall = {
    enable = true;

    # Only expose necessary external-facing ports
    allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS
      53317 # Local Send
      # ygg ports
      7991
      9002
      65533
    ];

    # UDP ports for various services
    allowedUDPPorts = [
      80 # HTTP/3
      443 # HTTP/3
      # ygg ports
      7991
      9002
      65533
    ];

    # Allow ping
    allowPing = true;
  };

  nixpkgs.config.allowUnfree = true;

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
        "syncthing/thinkpadt490s/cert.pem" = {
          format = "binary";
          owner = config.users.users.eugene.name;
          mode = "0600";
          sopsFile = ../syncthing/thinkpadt490s/cert.pem;
        };
        "syncthing/thinkpadt490s/key.pem" = {
          format = "binary";
          owner = config.users.users.eugene.name;
          mode = "0600";
          sopsFile = ../syncthing/thinkpadt490s/key.pem;
        };
        yggdrasil_config = {
          format = "binary";
          sopsFile = ../yggdrasil/yggdrasil.conf;
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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
      };
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}
