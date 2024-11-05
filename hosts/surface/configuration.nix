# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, flakes, ... }:
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  # Rebuild switch twice per day
  system.autoUpgrade.enable = true;

  virtualisation = {
    waydroid.enable = true;
  };

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

  # Set your time zone.
  time.timeZone = "America/Boise";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  programs = {};

  services = {
    # KDE
    xserver.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  # Enable sound with pipewire.
  security.rtkit.enable = true;

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

  fonts.packages = [
    #flakes.mgord9518-nur.windows-fonts
  ];

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

  # Don't wait until online to continue booting, this improves startup time
  systemd.services.NetworkManager-wait-online.enable = false;

  swapDevices = [
#    {
#      device = "/var/lib/swapfile";
#
#      # 16iGB
#      size = 16 * 1024;
#    }
  ];

  environment.sessionVariables = rec {
    BROWSER = "librewolf";

    # Keyboard options
    # Swap ESC and CAPS LOCK
    XKB_DEFAULT_OPTIONS = "caps:swapescape";

    FLTK_SCALE_FACTOR = "1.5";

    CC  = "zig cc";
    CXX = "zig c++";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
