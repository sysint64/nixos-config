{ lib, config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelParams = [
  #   "iommu=pt"
  #   "ttm.pages_limit=31457280"       # 120 GB in 4K pages
  #   "ttm.page_pool_size=15728640"    # 60 GB pre-allocated pool
  # ];
  boot.kernelParams = [
    "amd_iommu=off"
    "amdgpu.gttsize=126976"
    "ttm.pages_limit=32505856"
    "ttm.page_pool_size=32505856"
  ];

  hardware.amdgpu.initrd.enable = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  systemd.tmpfiles.rules = [
    "z /mnt/storage 0755 andrei users -"
    "d /mnt/storage/llm 0755 ollama ollama -"
    "Z /mnt/storage/llm/models 0755 ollama ollama -"
  ];

  services.power-profiles-daemon.enable = true;
  services.blueman.enable = true;
  services.gvfs.enable = true;
  services.flatpak.enable = true;
  services.searx = {
    enable = true;
    settings = {
      server = {
        port = 8888;
        bind_address = "127.0.0.1";
        secret_key = "c7b9e2f9-13fc-49e2-a58f-8968831cf3e7";
      };
      search.formats = [ "html" "json" ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome  # handles screencast/screenshot on Wayland
    ];
    config.common.default = "gtk";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  networking.hostName = "main";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;

  time.timeZone = "Europe/Helsinki";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fi_FI.UTF-8";
    LC_IDENTIFICATION = "fi_FI.UTF-8";
    LC_MEASUREMENT = "fi_FI.UTF-8";
    LC_MONETARY = "fi_FI.UTF-8";
    LC_NAME = "fi_FI.UTF-8";
    LC_NUMERIC = "fi_FI.UTF-8";
    LC_PAPER = "fi_FI.UTF-8";
    LC_TELEPHONE = "fi_FI.UTF-8";
    LC_TIME = "fi_FI.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  # services.gnome.gnome-keyring.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;

    wireplumber.extraConfig."11-bluetooth-policy" = {
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
      "monitor.bluez.properties" = {
        # LDAC doesn't work :(
        "bluez5.codecs" = [ "aptx_hd" "aptx" "aac" "sbc" ];
      };
    };
  };

  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
        user = "greeter";
      };
    };
  };
  services.udisks2.enable = true;

  fonts.packages = with pkgs; [
    font-awesome
    fantasque-sans-mono
    fira-sans
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.andrei = {
    isNormalUser = true;
    description = "Andrei";
    extraGroups = [ "networkmanager" "wheel" "kvm" "render" "video" "dialout" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;
  programs.niri.enable = true;
  programs.zsh.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-volman
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    libGL
    libx11
    libxcursor
    libxrandr
    libxi
    gtk3
    glib
    pango
    cairo
    atk
    gdk-pixbuf
    fontconfig
    freetype
    harfbuzz
  ];

  programs.xfconf.enable = true;
  programs.dconf.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.backupFileExtension = "backup";
  home-manager.users.andrei = import ../../home/andrei.nix;

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    models = "/mnt/storage/llm/models";
    user = "ollama";
    group = "ollama";
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "-1";
    };
    # Optional: preload models, see https://ollama.com/library
    # loadModels = [ "llama3.2:3b" "deepseek-r1:1.5b"];
  };

  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
    home = "/var/lib/ollama";
  };
  users.groups.ollama = {};

  systemd.services.ollama = {
    unitConfig.RequiresMountsFor = [ "/mnt/storage/llm/models" ];
  };

  systemd.services.ollama.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "ollama";
    Group = "ollama";
    ReadWritePaths = [ "/mnt/storage/llm/models" ];
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.containers.open-webui = {
    image = "ghcr.io/open-webui/open-webui:main";
    ports = [ "8080:8080" ];
    volumes = [ "open-webui:/app/backend/data" ];
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      WEBUI_AUTH = "False";
    };
    extraOptions = [ "--network=host" ];  # simplest way to reach Ollama on localhost
  };

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };

  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    git
    tree
    gcc
    python3
    btop
    htop
    bluez
    bluez-tools
    jdk17
    opencode
    solaar
    kitty

    foot
    wmenu
    wl-clipboard
    grim
    slurp
    swaybg
    gimp

    cargo-binutils
    llvmPackages.bintools
    python3Packages.huggingface-hub
    llama-cpp
    distrobox

    gnumake
    rocmPackages.clr
    rocmPackages.hipcc
    rocmPackages.rocminfo
    rocmPackages.rocblas
    rocmPackages.hipblas
    rocmPackages.hipblaslt
    rocmPackages.rocwmma
  ];

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  environment.variables = {
    ANDROID_HOME = "/mnt/storage/dev/android/sdk";
    ANDROID_SDK_ROOT = "/mnt/storage/dev/android/sdk";
    GRADLE_USER_HOME = "/mnt/storage/dev/android/gradle";
    JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
    OPENCODE_ENABLE_EXA = "true";

    RUSTUP_HOME = "/mnt/storage/dev/rust/rustup";
    CARGO_HOME = "/mnt/storage/dev/rust/cargo";

    FVM_CACHE_PATH = "/mnt/storage/dev/flutter/fvm";
    PUB_CACHE = "/mnt/storage/dev/flutter/pub-cache";

    HEX_HOME = "/mnt/storage/dev/elixir/hex";
    MIX_HOME = "/mnt/storage/dev/elixir/mix";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11";
}
