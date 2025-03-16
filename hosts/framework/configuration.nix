{ inputs, config, pkgs, lib, flakes, ... }:
let
  garbageHome = config.users.users.mgord9518.home + "/.local/garbage";
  steamHome = garbageHome + "/steam";
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
    ];

    binfmt.emulatedSystems = [
      "aarch64-linux"
    ];

    kernelModules = [
      "ecryptfs"
    ];

    plymouth = {
      enable = true;
      theme = "bgrt";
#      themePackages = with pkgs; [
#        # By default we would install all themes
#        (adi1090x-plymouth-themes.override {
#          selected_themes = [ "hexagon_dots_alt" ];
#        })
#      ];
    };

    consoleLogLevel = 0;
    initrd.verbose = false;

    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
  };

  networking = {
    hostName = "framework";

    # Enable networking
    networkmanager.enable = true;

    # Open ports in the firewall.
    firewall.allowedTCPPortRanges = [
      # GSConnect
      { from = 1714; to = 1764; }
    ];

    firewall.allowedUDPPortRanges = [
      # GSConnect
      { from = 1714; to = 1764; }
    ];

    firewall.allowedTCPPorts = [
      # Python HTTP server default
      8000

      3000
    ];
  
    firewall.allowedUDPPorts = [];
  };

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      #dedicatedServer.openFirewall = true;

      package = pkgs.steam.override {
        # Workaround X11 cursor issue
        extraPkgs = pkgs: with pkgs; [
          adwaita-icon-theme
        ];

        # Prevent Steam from dumping files directly in our real $HOME
        extraEnv = { HOME = steamHome; };
        extraProfile = ''
          mkdir -p "${steamHome}"
        '';
      };
    };
  };

  services = {
    # GNOME
    xserver.enable = true;
    xserver.desktopManager.gnome.enable = true;
    xserver.displayManager.gdm.enable = true;

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
     gimp
     godot_4
     #openrct2
     lutris
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];

  environment.systemPackages = with pkgs; [
    # System GUI utils
    gdm-settings

    # System CLI utils
    pv
    gnupg
    imagemagick

    # Extra CLI utils
    jq
    bubblewrap
    qemu

    # Programming languages
    go
    python3
    zig

    # Disk management
    exfatprogs
    popsicle

    # Fix Steam cursor
    xsettingsd
    xorg.xrdb

    adw-gtk3

    (pkgs.writeShellScriptBin "wget" ''
      ${pkgs.wget}/bin/wget --no-hsts
    '')
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
    GTK_THEME = "adw-gtk3-dark";

    #STEAM_FORCE_DESKTOPUI_SCALING = "1.5";

    #COSMIC_DATA_CONTROL_ENABLED = "1";

    CC  = "zig cc";
    CXX = "zig c++";
  };

  home-manager = {
    users.mgord9518 = import ./home.nix;
    extraSpecialArgs = { inherit inputs; inherit flakes; };
  };

  system.stateVersion = "25.05";
}
