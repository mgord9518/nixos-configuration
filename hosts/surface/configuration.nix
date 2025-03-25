{ config, pkgs, lib, flakes, ... }: {
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelParams = [
      "mem_sleep_default=deep"
    ];
  };

  networking = {
    hostName = "surface";

    # Enable networking
    networkmanager.enable = true;
  };

  programs = {};

  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;

      excludePackages = with pkgs; [ xterm ]; 
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mgord9518 = {
    isNormalUser = true;
    description = "Mathew Gordon";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    packages = with pkgs; [
      gimp
      godot_4
      openrct2
    ];
  };

  fonts.packages = [];

  environment.systemPackages = with pkgs; [
    # System CLI utils
    pv
    gnupg
    imagemagick

    # Extra CLI utils
    jq
    bubblewrap
    flakes.mist

    # Programming languages
    go
    python3
    zig

    # Disk management
    exfatprogs
  ];

  system.stateVersion = "23.05";
}
