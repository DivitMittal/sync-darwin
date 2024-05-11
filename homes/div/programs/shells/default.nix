{ config, pkgs, ... }:

{
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  home.sessionVariables = {
    EDITOR   = "nvim"; VISUAL = "nvim";
    PAGER    = "less"; LESS   = "--RAW-CONTROL-CHARS --mouse -C --tilde --tabs=2 -W --status-column -i"; LESSHISTFILE = "-";
    LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s"; LESSCOLORIZER = "bat";
    SCREENRC = "${config.xdg.configHome}/screen/screenrc";
  };

  home.shellAliases  = {
    man               = "batman";
    cat               = "bat --paging=never";
    pip-uninstall-all = "pip freeze | cut -d '@' -f1 | xargs pip uninstall -y";
    lt                = "eza --tree --level=2 | ov -H1";
    ll                = "eza -albhHigUuS -m@ | ov -H1";
  };

  imports = [
    ./fish.nix
    ./zsh.nix
    ./bash.nix
  ];
}