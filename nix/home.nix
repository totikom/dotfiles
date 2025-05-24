{ config, pkgs, ... }:
{
  home-manager.users.eugene = {
    # Home Manager needs a bit of information about you and the paths it should
    # manage.
    home.username = "eugene";
    home.homeDirectory = "/home/eugene";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "25.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = with pkgs; [
      alacritty
      dotter
      eza
      firefox
      htop
      ncdu
      neofetch
      nixfmt-rfc-style

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
    home.file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    home.sessionVariables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
    };
    programs = {
      zoxide = {
        enable = true;
      };
      bat = {
        enable = true;
      };
      git = {
        enable = true;
        delta.enable = true;
        userName = "Eugene Lomov";
        userEmail = "eugene.lomov@protonmail.com";
        ignores = [
          "*.swp"
        ];
        signing = {
          key = "3197B6B3AE53574B";
          signByDefault = true;
        };
        extraConfig.push.autoSetupRemote = true;
      };
      gitui = {
        enable = true;
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
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
      };
      zellij = {
        enable = true;
        enableZshIntegration = true;
        attachExistingSession = true;
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
    home.sessionVariables = {
      # EDITOR = "emacs";
    };
    xsession.windowManager.i3 = {
      enable = true;
      config = {
        modifier = "Mod4";
        terminal = "alacritty";
        bars = [
          {
            position = "top";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config-default.toml";
          }
        ];
      };
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
