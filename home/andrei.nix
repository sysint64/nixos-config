{ pkgs, lib, inputs, ... }:

{
  imports = [
    ./modules/emacs.nix
    ./modules/niri.nix
    ./modules/flutter.nix
    ./modules/rust.nix
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

  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      # package = pkgs.papirus-icon-theme.override { color = "yaru"; };
      package = pkgs.papirus-icon-theme.override { color = "yellow"; };
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.theme = null;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };

  programs.yazi = {
    enable = true;
    plugins = {
      full-border = "${pkgs.yaziPlugins.full-border}";
    };
    initLua = ''
      require("full-border"):setup()
    '';
    flavors = {
      kanagawa = pkgs.fetchFromGitHub {
        owner = "dangooddd";
        repo = "kanagawa.yazi";
        rev = "main";
        hash = "sha256-Yz0zRVzmgbrk0m7OkItxIK6W0WkPze/t09pWFgziNrw=";
      };
    };
    theme = {
      flavor = {
        dark = "kanagawa";
        light = "kanagawa";
      };
      # mgr = {
      #   border_symbol = "│";
      # };
    };
  };

  programs.neovim = {
    enable = true;
  };

  home.packages = with pkgs; [
    telegram-desktop
    discord
    simplex-chat-desktop
    speedcrunch
    stretchly
    ripdrag
    ghostty
    fastfetch
    claude-code
  ];
}
