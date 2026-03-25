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

  home.sessionVariables = {
    # Android Studio manages the SDK at this mutable path
    ANDROID_HOME = "$HOME/Android/Sdk";
    ANDROID_SDK_ROOT = "$HOME/Android/Sdk";
    JAVA_HOME = "${pkgs.jdk17.home}";
  };
}
