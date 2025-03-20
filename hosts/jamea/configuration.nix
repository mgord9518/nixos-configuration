{ flakes, config, pkgs, lib, ... }:
let
  steamHome = config.users.users.mgord9518.home + "/.local/garbage/steam";
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/xdg.nix
    ../../modules/common.nix
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    kernelParams = [
      "mem_sleep_default=deep"

      # Silent boot
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"

      "nvidia_drm.fbdev=1"
      "nvidia-drm.modeset=1"
      "module_blacklist=i915" 
    ];

    plymouth = {
      enable = true;
      theme = "bgrt";
    };

    consoleLogLevel = 0;
    initrd.verbose = false;

    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };

  # Don't wait for internet connection to come online when booting,
  # improves startup time
  systemd.services.NetworkManager-wait-online.enable = false;

  networking = {
    hostName = "jamea";
    networkmanager.enable = true;
  };

  services = {
    # Enable the X11 windowing system.
    xserver.enable = true;

    xserver.desktopManager.gnome.enable = true;
    xserver.displayManager.gdm.enable = true;
    displayManager.defaultSession = "gnome";
  
    ratbagd.enable = true;
  
    xserver.videoDrivers = [ "nvidia" ];
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

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;

      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
          # Workaround xorg cursor issue
          adwaita-icon-theme
        ];
        extraEnv = {
          HOME = steamHome;
        };
        extraProfile = ''
          mkdir -p "${steamHome}"
        '';
      };
    };
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
      pavucontrol
      mullvad-vpn
      dolphin-emu
      mpv
      wineWowPackages.stable
      unrar
      paprefs
      p7zip
      libnotify
      unzip
      jq
      cpulimit
      lutris
      git
      piper
      deluge
      handbrake
      lutris
      heroic
      librewolf

      adw-gtk3

      flakes.suyu
      
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

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPortRanges = [];

    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };

  environment.sessionVariables = rec {
    GTK_THEME = "adw-gtk3-dark";
  };

  home-manager = {
    users.mgord9518 = import ./home.nix;
    extraSpecialArgs = { inherit flakes; };
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
