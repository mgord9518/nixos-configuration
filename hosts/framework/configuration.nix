# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, flakes, ... }:
let
  garbageHome = config.users.users.mgord9518.home + "/.local/garbage";
  steamHome = garbageHome + "/steam";
  librewolfHome = garbageHome + "/librewolf";
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/xdg.nix
    ../../modules/common.nix
  ];

  virtualisation = {
    #waydroid.enable = true;
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
          kdePackages.breeze
        ];

        # Prevent Steam from dumping files directly in $HOME
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
    flakes.mist

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

    STEAM_FORCE_DESKTOPUI_SCALING = "1.5";

    COSMIC_DATA_CONTROL_ENABLED = "1";

    CC  = "zig cc";
    CXX = "zig c++";
  };


programs.bash = {
  interactiveShellInit = ''
    exec mist
  '';
};

  home-manager.users.mgord9518 = import ./home.nix;

  system.stateVersion = "25.05";
}
