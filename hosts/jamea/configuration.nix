# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, suyu, ... }:
let
  steamHome = config.users.users.mgord9518.home + "/.local/garbage/steam";
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/xdg.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "nvidia_drm.fbdev=1"
    "nvidia-drm.modeset=1"
    "module_blacklist=i915" 
  ];

  # Don't wait for internet connection to come online when booting,
  # improves startup time
  systemd.services.NetworkManager-wait-online.enable = false;

  nix = {
    settings.auto-optimise-store = true;

    settings.use-xdg-base-directories = true;

    settings.experimental-features = [ 
      "nix-command"
      "flakes"
    ];
  };

  xdg.icons.fallbackCursorThemes = [ "breeze" ];

  networking = {
    hostName = "jamea";
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Boise";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services = {
    flatpak.enable = true;

    # Enable the X11 windowing system.
    xserver.enable = true;
  
    # Enable the KDE Plasma Desktop Environment.
    displayManager.sddm.enable = true;
    displayManager.defaultSession = "plasmax11";
    #displayManager.defaultSession = "plasma";
  
    desktopManager.plasma6.enable = true;

    ratbagd.enable = true;
  
    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    xserver.videoDrivers = [ "nvidia" ];

    pipewire = {
      enable = true;
      alsa.enable = true;
      #alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    steam-hardware.enable = true;
  };
  
  # NVidia drivers
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;

    open = false;

    nvidiaSettings = true;
    # 560.35.03
    #package = config.boot.kernelPackages.nvidiaPackages.stable;
    #package = config.boot.kernelPackages.nvidiaPackages.production;

    # 565.57.01
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  security.rtkit.enable = true;

  nixpkgs.config.packageOverrides = pkgs: {
    
  };

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          # Workaround xorg cursor issue
          kdePackages.breeze
        ];
        extraEnv = {
          HOME = steamHome;
        };
        extraProfile = ''
          mkdir -p "${steamHome}"
        '';
      };
    };

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 5";
      flake = "/home/mgord9518/Nix";
    };

    kdeconnect.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mgord9518 = {
    isNormalUser = true;
    description = "mgord9518";
    extraGroups = [
      "networkmanager"
      "wheel"
      "jellyfin"
    ];

    packages = with pkgs; [
      discord
      kdePackages.kate
      pavucontrol
      mullvad-vpn
      dolphin-emu
      mpv
      wineWowPackages.stable
      unrar
      paprefs
      p7zip
      kdePackages.kdialog
      libnotify
      unzip
      jq
      cpulimit
      lutris
      kdePackages.breeze-gtk
      git
      piper
      deluge
      handbrake
      kdePackages.partitionmanager
      lutris
      heroic
      librewolf

      suyu.packages.x86_64-linux.suyu
      
      # Jellyfin server
      ffmpeg-full
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];
  };

  services = {
    mullvad-vpn.enable = true;

    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    openssh.enable = true;
    pulseaudio.enable = false;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "mgord9518";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables = {
    GTK_THEME = "Breeze";
    #FLAKE = "/home/mgord9518/Nix";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    kdePackages.breeze-gtk
  ];

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPortRanges = [];

    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
