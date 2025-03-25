{ inputs, config, pkgs, lib, flakes, ... }:
let
  user = "mgord9518";
  garbageHome = config.users.users.${user}.home + "/.local/garbage";
  steamHome = garbageHome + "/steam";
in rec {
  imports = [
    ./hardware-configuration.nix
    ./environment.nix
    ./boot.nix
    ../../modules/xdg.nix
    ../../modules/common.nix
    ../../modules/firefox-policies.nix
  ];

  networking = {
    hostName = "framework";

    # Enable networking
    networkmanager.enable = true;

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
        # Workaround cursor issue
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
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;

      excludePackages = with pkgs; [ xterm ]; 
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Mathew Gordon";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];

    packages = with pkgs; [
     godot_4
     #openrct2
     lutris
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-unwrapped"
  ];

  swapDevices = [
    {
      device = "/var/lib/swapfile";

      # 16GiB
      size = 16 * 1024;
    }
  ];

  home-manager = {
    users.${user} = import ./home.nix;
    extraSpecialArgs = { inherit user; systemConfig = config; inherit flakes; };

    users.gdm = { lib, ... }: {
      home.file.".local/config/monitors.xml".source = ./monitors.xml;

      home.stateVersion = "23.05";
    };
  };

  system.stateVersion = "25.05";
}
