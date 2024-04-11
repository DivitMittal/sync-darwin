{ pkgs, lib, inputs, ... }:

{
  environment.darwinConfig = "$HOME/sync-darwin/nix-darwin/flake.nix";
  system = {
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null; # Set Git commit hash for darwin-version.
    stateVersion          = 4;                                               # $ darwin-rebuild changelog
  };
  services.nix-daemon.enable = true;  # Auto upgrade nix package and the daemon service.
  nix = {
    package  = pkgs.nix;
    settings = {
      "experimental-features" = ["nix-command" "flakes"];
      "use-xdg-base-directories" = false;
      trusted-users = ["root" "div"];
      auto-optimise-store = true;
    };
  };
  nixpkgs = {
    hostPlatform = "x86_64-darwin";
    config = {
      allowBroken = true; allowUnfree = true; allowUnsupportedSystem = true; allowInsecure = true;
    };
  };

  time.timeZone = "Asia/Calcutta";

  networking = {
    computerName         = "L1";
    knownNetworkServices = ["Wi-Fi"];
    hostName             = "div-mbp";
    dns                  = ["1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"];
  };

  security.pam.enableSudoTouchIdAuth = true;
  system.defaults.CustomUserPreferences = import ./macOS.nix;

  environment.systemPackages = with pkgs;[
    bashInteractive zsh dash fish  # shells
    ed gnused nano vim # editors
    bc binutils diffutils findutils inetutils gnugrep gawk which gzip gnupatch screen gnutar indent gnumake wget (lib.hiPrio gcc) # GNU
    (uutils-coreutils.override {prefix = "";}) # GNU-alt
    curl git less ruby ## Other
  ];
  documentation = {
    enable      = true;
    doc.enable  = true; info.enable = true; man.enable  = true;
  };

  environment.shells = with pkgs;[bashInteractive zsh dash fish];

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config"     ; XDG_CACHE_HOME = "$HOME/.cache";
    XDG_STATE_HOME  = "$HOME/.local/state"; XDG_DATA_HOME  = "$HOME/.local/share";
    EDITOR          = "nvim"              ; VISUAL         = "nvim";
    PAGER           = "less"              ; LESS           = "--RAW-CONTROL-CHARS --mouse -C --tilde --tabs=2 -W --status-column -i"; LESSHISTFILE = "-";
    LANG                  = "en_US.UTF-8";
    ARCHFLAGS             = "-arch x86_64";
    SCREENRC              = "$HOME/.config/screen/screenrc";
    HOMEBREW_NO_ENV_HINTS = "1";
  };

  environment.shellAliases = {
    dt       = "env cd $HOME/Desktop/";
    dl       = "env cd $HOME/Downloads";
    ls       = "env ls -aF";
    ll       = "env ls -alHbhigUuS";
    v        = "vim";
    ed       = "ed -v -p ':'";
    showpath = ''echo $PATH | sed "s/ /\n/g"'';
    showid   = ''id | sed "s/ /\n/g"'';
  };

  programs = {
    nix-index.enable = true;
    man.enable       = true; info.enable      = true;

    bash = {
      enable               = true;
      enableCompletion     = false;
      interactiveShellInit = ''
        # [ -z "$PS1" ] && return                                             # exit if running non-interactively
        PS1='%F{cyan}%~%f %# '
        set -o vi

        export BASH_SILENCE_DEPRECATION_WARNING=1
        export BADOTDIR="$HOME/.config/bash"
        export HISTFILE=''${BADOTDIR:-$HOME}/.bash_history

        # shopt -s checkwinsize                                               # check window size after every command
        # [ -r "/etc/bashrc_$TERM_PROGRAM" ] && . "/etc/bashrc_$TERM_PROGRAM" # source a specific bashrc for Apple Terminal
      '';
    };

    zsh = {
      enable                   = true;
      # enableSyntaxHighlighting = true;
      # enableCompletion         = true;
      # enableFzfCompletion      = true;
      # enableFzfGit             = true;
      # enableFzfHistory         = true;
      promptInit = "PS1='%F{cyan}%~%f %# '";
      interactiveShellInit = ''
        [[ "$(locale LC_CTYPE)" == "UTF-8" ]] && setopt COMBINING_CHARS # UTF-8 with combining characters
        disable log                                                     # avoid conflict with /usr/bin/log
        setopt BEEP                                                     # beep on error

        unalias run-help  # Remove the default of run-help being aliased to man
        autoload run-help # Use zsh's run-help, which will display information for zsh builtins.

        # Default key bindings
        [[ -n ''${key[Delete]} ]] && bindkey "''${key[Delete]}" delete-char
        [[ -n ''${key[Home]} ]]   && bindkey "''${key[Home]}" beginning-of-line
        [[ -n ''${key[End]} ]]    && bindkey "''${key[End]}" end-of-line
        [[ -n ''${key[Up]} ]]     && bindkey "''${key[Up]}" up-line-or-search
        [[ -n ''${key[Down]} ]]   && bindkey "''${key[Down]}" down-line-or-search

        [ -r "/etc/zshrc_$TERM_PROGRAM" ] && . "/etc/zshrc_$TERM_PROGRAM" # Useful support for interacting with Terminal.app or other terminal programs
      '';
    };

    fish = {
      enable       = true;
      useBabelfish = true;
      vendor = {
        config.enable = true;
        completions.enable = true;
        functions.enable = true;
      };
      shellInit = ''
        set -g fish_greeting
      '';
      interactiveShellInit = ''
        set -g fish_greeting
        set -g fish_vi_force_cursor 1
        set -g fish_cursor_default block
        set -g fish_cursor_visual block
        set -g fish_cursor_insert line
        set -g fish_cursor_replace_one underscore
      '';
    };
  };

  users = {
    users.div = {
      description = "Divit Mittal";
      home        = "/Users/div";
      shell       = pkgs.fish;
      packages    = with pkgs;[
        nixfmt-rfc-style # Nix goodies
        babelfish
      ];
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts          = with pkgs;[(nerdfonts.override {fonts = ["CascadiaCode"];})];
  };

  homebrew = import ./homebrew.nix;
}

