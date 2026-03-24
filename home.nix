{ pkgs, lib, inputs, ... }:
let
  treesitGrammars = pkgs.emacsPackages.treesit-grammars.with-all-grammars;
in
{
  home.stateVersion = "25.11";

  home.file = {
    ".emacs.d/init.sample.el".source = "${inputs.emacs-config}/init.sample.el";
    ".emacs.d/loader.el".source = "${inputs.emacs-config}/loader.el";
    ".emacs.d/layers".source = "${inputs.emacs-config}/layers";
    ".emacs.d/snippets".source = "${inputs.emacs-config}/snippets";
    ".emacs.d/vendor".source = "${inputs.emacs-config}/vendor";
    ".emacs.d/early-init.el".text = ''
      (setq treesit-extra-load-path '("${treesitGrammars}/lib"))
    '';
  };

  home.activation.emacsInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.emacs.d
    mkdir -p ~/.org

    if [ ! -f ~/.emacs.d/init.el ]; then
      cp ${inputs.emacs-config}/init.sample.el ~/.emacs.d/init.el
      chmod u+w ~/.emacs.d/init.el
    fi
  '';

  home.packages = with pkgs; [
    emacs-all-the-icons-fonts
    cspell
    hack-font
  ];

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

  programs.niri.settings = {
    spawn-at-startup = [
      { command = [ "noctalia-shell" ]; }
      { command = [ "stretchly" ]; }
    ];

    prefer-no-csd = true;

    animations = {
      workspace-switch.enable = false;
      window-open.enable = false;
      window-close.enable = false;
      window-movement.enable = false;
      window-resize.enable = false;
      horizontal-view-movement.enable = false;
    };

    input = {
      keyboard.xkb = {
        layout = "us,ru";
      };
      focus-follows-mouse.enable = false;
    };

    layout = {
      focus-ring.enable = false;
      gaps = 8;
      default-column-width.proportion = 0.5;
      border = {
        enable = true;
        width = 2;
        active.color = "#518f62";
        inactive.color = "#505050";
      };
      preset-column-widths = [
        { proportion = 1.0 / 2.0; }
        { proportion = 1.0 / 3.0; }
        { proportion = 2.0 / 3.0; }
      ];
    };

    window-rules = [
      {
        geometry-corner-radius = let r = 6.0; in {
          top-left = r;
          top-right = r;
          bottom-left = r;
          bottom-right = r;
        };
        clip-to-geometry = true;
      }
      {
        matches = [
          { app-id = "^stretchly$"; }
        ];
        open-floating = true;
      }
    ];

    binds = {
      "Mod+T".action.spawn = "ghostty";
      "Mod+D".action.spawn = ["rofi" "-show" "drun"];
      "Mod+Tab".action.spawn = ["rofi" "-show" "window"];
      "Mod+E".action.spawn = "emacs";
      "Mod+K".action.spawn = "speedcrunch";
      "Mod+Q".action.close-window = [];
      "Mod+Q".repeat = false;
      "Mod+Equal".action.toggle-overview = [];
      "Mod+Equal".repeat = false;
      "Mod+Space".action.switch-layout = "next";

      "Mod+F".action.maximize-column = [];
      "Mod+Shift+F".action.expand-column-to-available-width = [];
      "Mod+A".action.fullscreen-window = [];

      "XF86AudioRaiseVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ];
      "XF86AudioLowerVolume".action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
      "XF86AudioMute".action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];

      "Mod+R".action.switch-preset-column-width = [];
      "Mod+Shift+R".action.switch-preset-window-height = [];
      "Mod+Left".action.focus-column-left = [];
      "Mod+Right".action.focus-column-right = [];
      # "Alt+Page_Up".action.focus-window-up = [];
      # "Alt+Page_Down".action.focus-window-down = [];

      "Mod+Shift+Left".action.move-column-left = [];
      "Mod+Shift+Right".action.move-column-right = [];
      # "Alt+Shift+Page_Up".action.move-window-up = [];
      # "Alt+Shift+Page_Down".action.move-window-down = [];

      "Mod+Home".action.focus-column-first = [];
      "Mod+End".action.focus-column-last = [];
      "Mod+Shift+Home".action.move-column-to-first = [];
      "Mod+Shift+End".action.move-column-to-last = [];

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;

      "Mod+Shift+1".action.move-window-to-workspace = 1;
      "Mod+Shift+2".action.move-window-to-workspace = 2;
      "Mod+Shift+3".action.move-window-to-workspace = 3;
      "Mod+Shift+4".action.move-window-to-workspace = 4;

      # "Alt+Down".action.focus-workspace-down = [];
      # "Alt+Up".action.focus-workspace-up = [];
      # "Alt+Shift+Down".action.move-window-to-workspace-down = [];
      # "Alt+Shift+Up".action.move-window-to-workspace-up = [];

      "Ctrl+Mod+C".action.set-column-width = "-10%";
      "Ctrl+Mod+V".action.set-column-width = "+10%";
      # "Ctrl+Alt+Comma".action.set-window-height = "+10%";
      # "Ctrl+Alt+M".action.set-window-height = "-10%";

      "Mod+Backspace".action.consume-or-expel-window-left = [];
      "Mod+Delete".action.consume-or-expel-window-right = [];

      "Mod+W".action.toggle-column-tabbed-display = [];
      "Mod+V".action.toggle-window-floating = [];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];
      "Mod+S".action.center-column = [];
      "Mod+Shift+S".action.center-visible-columns = [];

      "Mod+Shift+E".action.quit = [];

      "Mod+Escape".action.toggle-keyboard-shortcuts-inhibit = [];
      "Mod+Escape".allow-inhibiting = false;
    };
  };
}
