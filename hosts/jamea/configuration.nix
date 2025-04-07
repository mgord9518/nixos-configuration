{ flakes, config, pkgs, lib, ... }:
let
  steamHome = config.users.users.mgord9518.home + "/.local/garbage/steam";
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/xdg.nix
    ../../modules/common.nix
    ../../modules/firefox-policies.nix
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;

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
          # Workaround cursor issue
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
      wineWowPackages.stable
      handbrake
      lutris
      librewolf
      fragments
      inkscape
      gnome-boxes
      ventoy-full-gtk
      mission-center
      showtime

      adw-gtk3

      unrar
      p7zip

      flakes.suyu
      
      # Jellyfin server
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
    ];
  };

  fonts.packages = with pkgs; [
    corefonts
    vistafonts
  ];

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

  environment.gnome.excludePackages = (with pkgs; [
    epiphany # Gnome web
    totem # Video player
    gnome-tour
    gnome-system-monitor
    gnome-text-editor
  ]);

  home-manager = {
    users.mgord9518 = import ./home.nix;
    extraSpecialArgs = { inherit flakes; };
  };

  system.stateVersion = "24.05";
}
