{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    rustup
    pkg-config
    openssl
    gcc
  ];

  # home.sessionVariables = {
  #   RUSTUP_HOME = "/mnt/storage/dev/rust/rustup";
  #   CARGO_HOME = "/mnt/storage/dev/rust/cargo";
  # };

  # home.sessionPath = [
  #   "/mnt/storage/dev/rust/cargo/bin"
  # ];
}
