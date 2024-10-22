{ pkgs, environment, ... }:

{
  imports = [];

  # Dedupe files
  nix.settings.auto-optimise-store = true;

  nix.settings = {
    experimental-features = [ 
      "nix-command"
      "flakes"
    ];
  };

  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 5";
      flake = "/home/mgord9518/Nix";
    };

    kdeconnect.enable = true;
    partition-manager.enable = true;
  };

  services = {
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
    pulseaudio.enable = false;
    bluetooth.enable = true;
  };

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  environment.sessionVariables = {
    EDITOR  = "nvim";

    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";

    # Keyboard options
    # Swap ESC and CAPS LOCK
    XKB_DEFAULT_OPTIONS = "caps:swapescape";

    QT_QPA_PLATFORM   = "wayland";
    GTK_THEME         = "Breeze";
    GDK_BACKEND       = "wayland,x11";
    CLUTTER_BACKEND   = "wayland";
    #SDL_VIDEODRIVER   = "wayland";

    TERM = "xterm-256color";

    # Move some annoying files to more appropriate locations
    WINEPREFIX          = "$XDG_DATA_HOME/wine";
    LESSHISTFILE        = "$XDG_CACHE_HOME/lesshst";
    GOPATH              = "$XDG_CACHE_HOME/go";
    ZIG_LOCAL_CACHE_DIR = "$XDG_CACHE_HOME/zig/local";
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
    plasma5Packages.kimageformats
    discover
    mpv
    librewolf
    ktorrent

    kdePackages.kdialog
    kdePackages.breeze-gtk
  ];
}
