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

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocales = [ "ru_RU.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LC_CTYPE = "en_US.UTF8";
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
      LC_COLLATE = "ru_RU.UTF-8";
    };

  };
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

    speechd.enable = false;

    pcscd.enable = true;
    # Enable sound.
    # hardware.pulseaudio.enable = true;
    # OR
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
        brgenml1cupswrapper
        brgenml1lpr
        brlaser
        epson-escpr
      ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    mullvad-vpn.enable = true;
    udisks2.enable = true;

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
    fail2ban = {
      enable = true;
      maxretry = 5;
      ignoreIP = [
        "192.168.0.0/16"
      ];
      bantime = "1d";
    };
    v2raya.enable = true;

    yggdrasil = {
      openMulticastPort = true;
      settings = {
        Peers = [
          "quic://asia.deinfra.org:15015"
          "quic://ip4.01.msk.ru.dioni.su:9002"
          "tcp://ip4.01.msk.ru.dioni.su:9002"
          "tcp://srv.itrus.su:7991"
          "tls://ip4.01.msk.ru.dioni.su:9003"
          "ws://ip4.01.msk.ru.dioni.su:9004"
        ];
        MulticastInterfaces = [
          {
            Regex = ".*";
            Beacon = true;
            Listen = true;
            Password = "";
            Port = 55061;
          }
        ];
      };
    };

    syncthing = {
      openDefaultPorts = true;
      overrideFolders = true;
      user = "eugene";
      dataDir = "/home/eugene";
      overrideDevices = true;
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
              "Main-pc"
              "Redmi K80 Pro"
              "ThinkPad"
              "ThinkPadT490s"
            ];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "14";
            };
          };
          "Documents" = {
            id = "fp5rw-7j1x3";
            path = "~/Documents/Phone";
            devices = [
              "Main-pc"
              "Redmi K80 Pro"
              "ThinkPad"
              "ThinkPadT490s"
            ];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "14";
            };
          };
          "Main-pc videos" = {
            id = "zczny-swe3w";
            path = "~/Videos/Synced";
            devices = [
              "Main-pc"
              "ThinkPadT490s"
            ];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "14";
            };
          };
          "Main-pc junk" = {
            id = "tshjv-zsprm";
            path = "~/.junk/Synced";
            devices = [
              "Main-pc"
              "ThinkPadT490s"
            ];
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "14";
            };
          };
        };
      };
    };
     udev.extraRules = ''
                # ST-Link V2-1
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1", SYMLINK+="stlinkv2-1_%n"
                SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="0666", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1", SYMLINK+="stlinkv2-1_%n"
              '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.eugene = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "scanner"
      "lp"
      config.services.kubo.group
    ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBI3zcGyF5SimD6i8p5TS5WQJ25aOE6QI0SK90VyyK7r eugene@ThinkPadT490s"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY6/YkxtBtCjA1aVaWzeDBRsXirlYiMjFf06N64udog eugene@Main-pc"
    ];
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed firs
    borgbackup
    duperemove
    git
    htop
    nh
    nix-du
    sshfs
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
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
          chain allowIncoming {
            type filter hook input priority -100; policy accept;
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
      55060 # ssh
      55061 # local ygg
      # ygg ports
      15015
      65533
      7991
      9002
      9003
      9004
    ];

    # UDP ports for various services
    allowedUDPPorts = [
      80 # HTTP/3
      443 # HTTP/3
      55060 # ssh
      # ygg ports
      15015
      65533
      7991
      9002
      9003
      9004
    ];

    # Allow ping
    allowPing = true;
    pingLimit = "5/second";
  };

  nixpkgs.config.allowUnfree = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
      };
    };
  };
  hardware.sane = {
    enable = true;
    brscan4 = {
      enable = true;
      netDevices = {
        home = {
          model = "DCP-L2520DWR";
          ip = "192.168.1.69";
        };
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
