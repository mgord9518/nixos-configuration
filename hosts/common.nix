{ config, pkgs, environment, ... }:

{
  imports = [];

  nix.settings = {
    experimental-features = [ 
      "nix-command"
      "flakes"
    ];

    use-xdg-base-directories = true;

#    gc = {
#      automatic = true;
#      dates = weekly;
#      options = "--delete-older-than 7d";
#    };

    auto-optimise-store = true;
  };

  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 5";
      flake = config.users.users.mgord9518.home + "/Nix";
    };

    kdeconnect.enable = true;
    partition-manager.enable = true;
  };

  services = {
    pulseaudio.enable = false;
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
  };

  # Apply X11 keymap to Linux TTY
  console.useXkbConfig = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    bluetooth.enable = true;
  };

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  environment.sessionVariables = {
    EDITOR  = "nvim";

    # Keyboard options
    # Swap ESC and CAPS LOCK
    XKB_DEFAULT_OPTIONS = "caps:swapescape";

#    QT_QPA_PLATFORM   = "wayland";
    GTK_THEME         = "Breeze";
#    GDK_BACKEND       = "wayland,x11";
#    CLUTTER_BACKEND   = "wayland";
    #SDL_VIDEODRIVER   = "wayland";

    TERM = "xterm-256color";
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    xxd
    file
    git
    unzip
    wl-clipboard
    dash
    tmux
    btop
    mpv
    librewolf
    ktorrent
    home-manager

    kdePackages.kdialog
    kdePackages.kimageformats
    kdePackages.breeze-gtk
    kdePackages.ark
    kdePackages.kcalc
  ];
}
