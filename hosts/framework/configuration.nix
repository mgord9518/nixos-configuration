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
    libvirtd.enable = true;
    waydroid.enable = true;

    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelParams = [
      "mem_sleep_default=deep"
    ];

    binfmt.emulatedSystems = [
      "aarch64-linux"
    ];

    kernelModules = [
      "ecryptfs"
    ];
  };

  networking = {
    hostName = "framework";

    # Enable networking
    networkmanager.enable = true;

    # Open ports in the firewall.
    firewall.allowedTCPPorts = [
      # Python HTTP server default
      8000

      3000
    ];
  
    firewall.allowedUDPPorts = [];
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

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      #dedicatedServer.openFirewall = true;
    };

    virt-manager.enable = true;
    nix-ld.enable = true;
  };

  services = {
    # KDE
    xserver.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    fprintd.enable = true;
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
      blender
      gimp
      godot_4
      openrct2
      qt6.qtwebview
      qt6.qtwebengine
    ];
  };

  fonts.packages = [
    #flakes.mgord9518-nur.windows-fonts
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];

  environment.systemPackages = with pkgs; [
    # System CLI utils
    pv
    gnupg
    imagemagick
    qimgv

    # Extra CLI utils
    jq
    fzf
    squashfuse
    bubblewrap
    qemu
    flakes.mist

    #kdePackages.kio-gdrive
    #kdePackages.kaccounts-integration
    #kdePackages.kaccounts-providers

    # Programming languages
    go
    python3
    zig

    # Disk management
    udisks
    exfatprogs
  ];

  # Don't wait until online to continue booting, this improves startup time
  systemd.services.NetworkManager-wait-online.enable = false;

  swapDevices = [
    {
      device = "/var/lib/swapfile";

      # 16GiB
      size = 16 * 1024;
    }
  ];

  environment.sessionVariables = rec {
    BROWSER = "librewolf";

    # Keyboard options
    # Swap ESC and CAPS LOCK
    XKB_DEFAULT_OPTIONS = "caps:swapescape";

	FLTK_SCALE_FACTOR = "1.5";
	STEAM_FORCE_DESKTOPUI_SCALING = "1.5";

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
