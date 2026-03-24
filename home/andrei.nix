{ pkgs, lib, inputs, ... }:

{
  imports = [
    ./modules/emacs.nix
    ./modules/niri.nix
  ];

  home.stateVersion = "25.11";

  programs.git = {
    enable = true;
    settings = {
      user.name = "Andrei";
      user.email = "sys.int64@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  home.packages = with pkgs; [
    telegram-desktop
    speedcrunch
    stretchly
    yazi
    ripdrag
    ghostty
  ];
}
