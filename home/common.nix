{
  config,
  pkgs,
  lib,
  ...
}:
let
  mod = "Mod4";
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "eugene";
    homeDirectory = "/home/eugene";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "25.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    packages = with pkgs; [
      age
      bluetui
      cryfs
      deltachat-desktop
      dotter
      doublecmd
      eza
      firefox
      gcc
      gtrash
      htop
      image-roll
      joplin-desktop
      kmymoney
      libreoffice-still
      localsend
      maim
      mc
      ncdu
      neofetch
      nix-output-monitor
      nixfmt-rfc-style
      nmon
      pwvucontrol
      rustup
      signal-desktop
      simple-scan
      sops
      system-config-printer
      telegram-desktop
      usbutils
      veracrypt
      wifi-qr
      xclip
      xdotool
      xorg.xbacklight
      yubikey-manager
      yubioath-flutter
      zathura

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;
      ".background-image".source = ../i3/wallpaper.jpg;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };
    sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
    };
    shellAliases = {
      ls = "eza";
      ll = "eza -la";
      x = "gtrash put";
      ncdu = "ncdu --delete-command 'gtrash put'";
      cpr = "cp --reflink=always --recursive";
    };

    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/eugene/etc/profile.d/hm-session-vars.sh
    #
    sessionVariables = {
      # EDITOR = "emacs";
    };
  };

  programs = {
    bat.enable = true;
    fd.enable = true;
    gitui.enable = true;
    mpv.enable = true;
    ripgrep.enable = true;
    tealdeer.enable = true;
    zoxide.enable = true;

    alacritty = {
      enable = true;
      settings = {
        font.size = 8.0;
      };
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    git = {
      enable = true;
      settings = {
        user = {
          name = "Eugene Lomov";
          email = "eugene.lomov@protonmail.com";
        };
        push.autoSetupRemote = true;
        merge.tool = "vimdiff";
      };
      ignores = [
        "*.swp"
      ];
      signing = {
        key = "3197B6B3AE53574B";
        signByDefault = true;
      };
    };
    delta = {
      enable = true;
      enableGitIntegration = true;
    };
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
    vim = {
      enable = true;
      defaultEditor = true;
      settings = {
        history = 500;
        ignorecase = true;
        number = true;
        smartcase = true;
      };
      plugins = with pkgs.vimPlugins; [
        nerdcommenter
        vim-matchup
        auto-pairs
        vim-llvm
        vim-fugitive
        typst-vim
        tabular
        vim-markdown
        vim-easy-align
        rust-vim
        vim-gitgutter
        # vim-xkbswitch
      ];
      extraConfig = "
          set autoindent
          set cursorline
          set exrc
          set foldmethod=indent
          set hlsearch
          set incsearch
          set laststatus=2
          set ruler
          set secure
          set showmatch
          set showmode
          set smartindent
          set smarttab
          set wrap
          set autoread
          syntax on
          colorscheme koehler

          set wildmenu
          set wildmode=full,full
          :let mapleader = \",\"
          \" Start interactive EasyAlign in visual mode (e.g. vipga)
          xmap ga <Plug>(EasyAlign)

          \" Start interactive EasyAlign for a motion/text object (e.g. gaip)
          nmap ga <Plug>(EasyAlign)

          map ,, :w<CR>:Ctest<CR>
          map ,b :w<CR>:Cbench<CR>
          map ,c :w<CR>:Ccheck<CR>
          map ,d :w<CR>:Cdoc<CR>
          map ,f :RustFmt<CR>:w<CR>
          map ,l :w<CR>:Ctest --lib<CR>
          map ,p :w<CR>:Cdoc --document-private-items<CR>
          map ,q :w<CR>:Ctest -q<CR>
          map ,r :w<CR>:Crun<CR>
          \"Rust Embedded
          map ,e :w<CR>:Cargo embed<CR>
          ";
    };
    keepassxc = {
      enable = true;
      settings = {
        Browser = {
          Enabled = true;
          AllowExpiredCredentials = true;
        };
        GUI = {
          ApplicationTheme = "dark";
        };
        Security = {
          LockDatabaseIdle = true;
          LockDatabaseIdleSeconds = 300;
        };
      };
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        size = 50000;
        share = true;
        append = true;
        expireDuplicatesFirst = true;
        ignoreAllDups = true;
        ignoreDups = false;
        ignoreSpace = false;
      };
      historySubstringSearch = {
        enable = true;
        searchUpKey = [
          "$terminfo[kcuu1]"
        ];
        searchDownKey = [
          "$terminfo[kcud1]"
        ];
      };
      completionInit = ''
        autoload -U compinit && compinit
        ## case insensitive path-completion
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu select
      '';
      envExtra = (builtins.readFile ../zsh/mkdir_unbacked.sh);
    };
    zellij = {
      enable = true;
      enableZshIntegration = true;
      attachExistingSession = true;
      settings = {
        on_force_close = "detach";
        pane_frames = false;
        ui.pane_frames.hide_session_name = true;
        scroll_buffer_size = 100000;
        keybinds = {
          unbind = [
            "Ctrl q"
            "Ctrl o"
            "Ctrl n"
          ];
          normal = {
            "bind \"Ctrl k\"".SwitchToMode = "Resize";
            "bind \"Ctrl x\"".SwitchToMode = "Session";
          };
          resize."bind \"Ctrl k\"".SwitchToMode = "Normal";
          session."bind \"Ctrl x\"".SwitchToMode = "Normal";
        };
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = true;
        format = "$all";
        scan_timeout = 100;
      };
    };
    i3status-rust = {
      enable = true;
      bars = {
        default = {
          blocks = [
            {
              block = "music";
              format = " $icon {$combo.str(max_w:20) $play $next |}";
            }
            {
              block = "memory";
              interval = 5;
              warning_mem = 80;
              critical_mem = 95;
              warning_swap = 80;
              critical_swap = 95;
              format = " $icon $mem_total_used_percents.eng(w:2) ";
              format_alt = " $icon_swap $swap_free.eng(w:3,u:B,p:M)/$swap_total.eng(w:3,u:B,p:M)($swap_used_percents.eng(w:2)) ";
            }
            {
              block = "cpu";
              interval = 1;
            }
            { block = "sound"; }
            {
              block = "net";
              format = " $icon {$signal_strength $ssid |}";
              format_alt = " $icon ^icon_net_down $speed_down.eng(prefix:K) ^icon_net_up $speed_up.eng(prefix:K) ";
              theme_overrides = {
                idle_fg = {
                  link = "good_fg";
                };
                idle_bg = {
                  link = "good_bg";
                };
              };
            }
            {
              block = "vpn";
              driver = "mullvad";
              interval = 10;
              format_connected = "$icon ";
              format_disconnected = " $icon ";
              state_connected = "good";
              state_disconnected = "critical";
            }
            {
              block = "battery";
              interval = 10;
              format = " $icon $percentage $time ";
              full_threshold = 99;
              info = 50;
              warning = 30;
              critical = 10;
              empty_threshold = 1;
              theme_overrides = {
                idle_fg = {
                  link = "good_fg";
                };
                idle_bg = {
                  link = "good_bg";
                };
              };
            }
            {
              block = "time";
              interval = 5;
              format = " $icon $timestamp.datetime(f:'%a %d/%m %R') ";
            }
          ];
          icons = "awesome5";
          theme = "solarized-dark";
        };
      };
    };
    rofi = {
      enable = true;
      terminal = "${pkgs.alacritty}/bin/alacritty";
    };
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        sort_by = "natural";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_hidden = true;
        show_symlink = true;
      };
    };
  };
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = mod;
      terminal = "alacritty";
      menu = "\"${pkgs.rofi}/bin/rofi -modi drun,run -show drun\"";
      defaultWorkspace = "workspace number 1";
      workspaceLayout = "tabbed";
      fonts = {
        names = [ "pango" ];
        style = "monospace";
        size = 12.0;
      };
      gaps = {
        smartBorders = "on";
        smartGaps = true;
      };
      keybindings = lib.mkOptionDefault {
        # Screen birghtness
        "XF86MonBrightnessUp" = "exec xbacklight -inc 5";
        "XF86MonBrightnessDown" = "exec xbacklight -dec 5";
        "Shift+XF86MonBrightnessUp" = "exec xbacklight -inc 1";
        "Shift+XF86MonBrightnessDown" = "exec xbacklight -dec 1";

        # Sound
        "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_SINK@ 10%+";
        "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_SINK@ 10%-";
        "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_SINK@ toggle";

        # Apps
        "${mod}+z" = "exec firefox";
        "${mod}+x" = "exec doublecmd";

        # Move focus
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        # Move window
        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # Layout
        "${mod}+e" = "layout default";
        "${mod}+y" = "split horizontal";
        "${mod}+v" = "split vertical";

        # Containers
        "${mod}+p" = "focus parent";
        "${mod}+c" = "focus child";

        "${mod}+Shift+e" = ''mode "$system_mode"'';
        "${mod}+Shift+x" = "exec betterlockscreen -l dim --off 30";

        # Screenshots
        "Print" = ''exec --no-startup-id maim "/home/$USER/Pictures/$(date)"'';
        "${mod}+Print" =
          ''exec --no-startup-id maim --window $(xdotool getactivewindow) "/home/$USER/Pictures/$(date)"'';
        "Shift+Print" = ''exec --no-startup-id maim --select "/home/$USER/Pictures/$(date)"'';

        # Clipboard Screenshots
        "Ctrl+Print" = "exec --no-startup-id maim | xclip -selection clipboard -t image/png";
        "Ctrl+${mod}+Print" =
          "exec --no-startup-id maim --window $(xdotool getactivewindow) | xclip -selection clipboard -t image/png";
        "Ctrl+Shift+Print" = "exec --no-startup-id maim --select | xclip -selection clipboard -t image/png";

      };
      modes = {
        resize = {
          h = "resize shrink width 10 px or 10 ppt";
          j = "resize grow height 10 px or 10 ppt";
          k = "resize shrink height 10 px or 10 ppt";
          l = "resize grow width 10 px or 10 ppt";
          Escape = "mode default";
          Return = "mode default";
          r = "mode default";
        };
        "$system_mode" = {
          l = "exec --no-startup-id i3-msg exit, mode default";
          s = "exec --no-startup-id systemctl suspend, mode default";
          r = "exec --no-startup-id systemctl reboot, mode default";
          "Shift + s" = "exec --no-startup-id systemctl poweroff -i, mode default";
          Escape = "mode default";
          Return = "mode default";
        };

      };
      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
        }
      ];
    };
    extraConfig = "set $system_mode System (l) logout, (s) suspend, (r) reboot, (Shift+s) shutdown";
  };
  services = {
    betterlockscreen = {
      enable = true;
      inactiveInterval = 10;
      arguments = [
        "dim"
        "--off"
        "30"
      ];
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";
      "x-scheme-handler/magnet" = "userapp-transmission-gtk-IKDBC3.desktop";
      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "text/markdown" = "gvim.desktop";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
