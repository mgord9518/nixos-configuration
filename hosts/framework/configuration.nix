# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    # Modular config
    ./modules/environ.nix
    ./modules/sh.nix
    ./modules/hosts.nix
    ./modules/podman.nix
  ];

  # Rebuild switch twice per day
  system.autoUpgrade.enable = true;

  # Dedupe files
  nix.settings.auto-optimise-store = true;

  virtualisation.libvirtd.enable = true;
  virtualisation.waydroid.enable = true;

  nix.settings = {
    experimental-features = [ 
      "nix-command"
      "flakes"
    ];
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

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 5";
      flake = "/home/mgord9518/Nix";
    };

    virt-manager.enable = true;
    nix-ld.enable = true;
    kdeconnect.enable = true;
    partition-manager.enable = true;
  };

  services = {
    # KDE
    xserver.enable = true;
    desktopManager.plasma6.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    flatpak.enable = true;

    mullvad-vpn = {
      enable  = true;
      package = pkgs.mullvad-vpn;
    };

    xserver = {
      xkb.layout  = "us";
      xkb.variant = "";
      autorun     = false;

      # Configure keymap
      xkb = {
        options = "caps:swapescape";
      };
    };

    # Pipewire for sound
    pipewire = {
      enable            = true;
      alsa.enable       = true;
      alsa.support32Bit = true;
      pulse.enable      = true;
    };

    thermald.enable = true;
    fprintd.enable = true;
  };

  # Apply X11 keymap to Linux TTY
  console.useXkbConfig = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;

  hardware = {
    pulseaudio.enable = false;
    bluetooth.enable = true;
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
  };

  # Only enabled for Steam
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # System CLI utils
    neovim
    wget
    xxd
    file
    git
    podman
    unzip
    ecryptfs
    wl-clipboard
    pv
    gnupg
    dash
    tmux
    imagemagick
    kdePackages.kdialog
    kdePackages.breeze-gtk
    qimgv
    # Extra image formats
    plasma5Packages.kimageformats

    # Extra CLI utils
    jq
    fzf
    squashfuse
    bubblewrap
    btop
    qemu

    # System GUI utils
    brightnessctl
    libinput
    wayland
    libxkbcommon
    discover

    # Extra GUI utils
    blender
    dolphin
    mpv
    gimp
    godot_4

    # Programming languages
    go
    python3
    zig

    # Internet
    librewolf
    ktorrent

    # Disk management
    udisks
    exfatprogs
  ];

  fonts.packages = with pkgs; [];

  # Don't wait until online to continue booting, this improves startup time
  systemd.services.NetworkManager-wait-online.enable = false;

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  swapDevices = [
    {
      device = "/var/lib/swapfile";

      # 16iGB
      size = 16 * 1024;
    }
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
