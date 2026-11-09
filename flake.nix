{
  description = "NixOS configuration with Noctalia";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    emacs-config = {
      url = "github:sysint64/.emacs.d";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      # v5.3.0 (2026-10-21). Pinned: `nix flake update` would silently float
      # this and re-break the boot. Boot-crash seen earlier was the stale
      # noctalia unit running July binaries vs mesa 26.2 (glibc skew,
      # noctalia#4668) — fixed by removing ~/.gtkrc-2.0.backup and the
      # yazi theme.toml.backup so Home Manager activation completes.
      url = "github:noctalia-dev/noctalia-shell/86ab912ea30928fcc2ff68e4e9431b0a2ff8b576";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ds4 = {
    #   # DS4 / DwarfStar ROCm build for Strix Halo (gfx1151).
    #   url = "git+file:///home/andrei/projects/ds4";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.main = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        inputs.niri.nixosModules.niri
        inputs.mango.nixosModules.mango
        home-manager.nixosModules.home-manager
        ./hosts/main/configuration.nix
        ./hosts/main/hardware-configuration.nix
      ];
    };

    # Offline installer ISO that embeds the full closure of `main` (which now
    # includes the prebuilt ds4 binaries + ROCm runtime). Build with:
    #   nix build .#nixosConfigurations.iso.config.system.build.isoImage
    # Boot it, partition/mount your target at /mnt, then run:
    #   install-ds4-system --root /mnt
    # which installs the prebuilt system straight from the ISO store — no network.
    # nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
    #   specialArgs = { inherit inputs; };
    #   modules = [
    #     "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    #     ({ pkgs, lib, ... }:
    #       let target = self.nixosConfigurations.main.config.system.build.toplevel;
    #       in {
    #         # Pull the entire target-system closure into the ISO's Nix store so
    #         # installation copies locally instead of fetching from the internet.
    #         system.extraDependencies = [ target ];

    #         # Fixed path to the prebuilt system + a one-shot offline installer.
    #         environment.etc."ds4-target-system".source = target;
    #         environment.systemPackages = [
    #           (pkgs.writeShellScriptBin "install-ds4-system" ''
    #             set -euo pipefail
    #             echo "Installing prebuilt system from the ISO store:"
    #             echo "  ${target}"
    #             exec nixos-install --no-channel-copy --system ${target} "$@"
    #           '')
    #         ];

    #         isoImage.isoName = lib.mkForce "nixos-ds4-offline.iso";
    #       })
    #   ];
    # };
  };
}
