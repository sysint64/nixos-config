{ pkgs, lib, inputs, ... }:

{
  home.packages = with pkgs; [
    # Android Studio (FHS-wrapped, manages its own SDK)
    android-studio
    jdk17

    # Build dependencies
    unzip
    xz
    zip
    libGLU
    libGL

    # Flutter version manager
    fvm

    cmake
    (lib.setPrio 15 clang)
    ninja
    pkg-config
    gtk3.dev
    gtk3

    # eglinfo
    mesa-demos
  ];
}
