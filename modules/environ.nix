{ environment, ... }:

{
  environment.sessionVariables = rec {
    EDITOR  = "nvim";
    BROWSER = "librewolf";

    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";

    XDG_BIN_HOME    = "$HOME/.local/bin";
    PATH = [ 
      "$XDG_BIN_HOME"
    ];

    # Keyboard options
    # Swap ESC and CAPS LOCK
    XKB_DEFAULT_OPTIONS = "caps:swapescape";

	FLTK_SCALE_FACTOR = "1.5";
	STEAM_FORCE_DESKTOPUI_SCALING = "1.5";

    QT_QPA_PLATFORM   = "wayland";
    GTK_THEME         = "Breeze:dark";
    GDK_BACKEND       = "wayland,x11";
    CLUTTER_BACKEND   = "wayland";
    #SDL_VIDEODRIVER   = "wayland";

    TERM = "xterm-256color";

    CC  = "zig cc";
    CXX = "zig c++";

    # Move some annoying files to more appropriate locations
    WINEPREFIX          = "$XDG_DATA_HOME/wine";
    LESSHISTFILE        = "$XDG_CACHE_HOME/lesshst";
    GOPATH              = "$XDG_CACHE_HOME/go";
    ZIG_LOCAL_CACHE_DIR = "$XDG_CACHE_HOME/zig/local";
  };
}
