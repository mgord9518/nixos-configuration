# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, flakes, ... }:
let
  garbageHome = config.users.users.mgord9518.home + "/.local/garbage";
  steamHome = garbageHome + "/steam";
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/xdg.nix
    ../../modules/common.nix
    ../../modules/kde_configuration.nix
  ];

  virtualisation = {
    libvirtd.enable = true;
    waydroid.enable = true;
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

    nvf = {
      enable = true;
      settings.vim = {
        useSystemClipboard = true;
        undoFile.enable    = true;
        searchCase         = "ignore";

        theme = {
          enable = true;
          name   = "gruvbox";
          style  = "dark";
        };

        languages = {
          nix.enable    = true;
          zig.enable    = true;
          clang.enable  = true;
          nim.enable    = true;
          rust.enable   = true;
          go.enable     = true;
          python.enable = true;
        };

        options = {
          shiftwidth = 4;
        };

        luaConfigPost = ''
          -- Restore cursor position
          vim.api.nvim_create_autocmd({ "BufReadPost" }, {
              pattern = { "*" },
              callback = function()
                  vim.api.nvim_exec('silent! normal! g`"zv', false)
              end,
          })
        '';
      };
    };
  };

  services = {
    # KDE
    xserver.enable = true;
    desktopManager.plasma6.enable = true;
    #displayManager.defaultSession = "plasma";

    #desktopManager.cosmic.enable = true;
    #displayManager.cosmic-greeter.enable = true;

    xserver.displayManager.lightdm.enable = false;

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
      openrct2
      qt6.qtwebview
      qt6.qtwebengine
      lutris
    ];
  };

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

    # Fix Steam cursor
    xsettingsd
    xorg.xrdb

    (pkgs.writeShellScriptBin "librewolf" ''
      HOME="${librewolfHome}" ${pkgs.librewolf}/bin/librewolf
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
    BROWSER = "librewolf";

    # Keyboard options
    # Swap ESC and CAPS LOCK
    XKB_DEFAULT_OPTIONS = "caps:swapescape";

    FLTK_SCALE_FACTOR = "1.5";
    STEAM_FORCE_DESKTOPUI_SCALING = "1.5";

    COSMIC_DATA_CONTROL_ENABLED = "1";

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
