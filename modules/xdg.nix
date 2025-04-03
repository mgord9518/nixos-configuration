# Keeps non-XDG-compliant programs from dumping everything in ~
# See <https://wiki.archlinux.org/title/XDG_Base_Directory>

{ config, pkgs, lib, ... }:
let
  home       = "$HOME";
  local      = "${home}/.local";
  cacheHome  = "${local}/cache";
  configHome = "${local}/config";
  dataHome   = "${local}/share";
  stateHome  = "${local}/state";

  # For THOSE *caugh* Steam *caugh* programs that just pull the $HOME
  # environment var and crap there with no way to override, let's fake it
  # This isn't without issue though, shells will now start at this location
  # so it'll need to be selectively overridden back to the real home in
  # those cases
  garbageHome = "${local}/garbage";
in {
  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = cacheHome;
    XDG_CONFIG_HOME = configHome;
    XDG_DATA_HOME   = dataHome;
    XDG_STATE_HOME  = stateHome;

    WINEPREFIX = "${dataHome}/wine_prefix";

    # Configurations
    GTK_RC_FILES      = "${configHome}/gtk/1.0/gtkrc";
    GTK2_RC_FILES     = "${configHome}/gtk/2.0/gtkrc";
    GTK3_RC_FILES     = "${configHome}/gtk/3.0/gtkrc"; # TODO: does this work?
    GTK4_RC_FILES     = "${configHome}/gtk/4.0/gtkrc"; # TODO: does this work?
    GIT_CONFIG_GLOBAL = "${configHome}/git_config";
    XCOMPOSEFILE      = "${configHome}/X11/xcompose";
    ZDOTDIR           = "${configHome}/zsh";
    WGETRC            = "${configHome}/wgetrc";

    # Programming language caches
    GOMODCACHE          = "${cacheHome}/go/mod";
    ZIG_LOCAL_CACHE_DIR = "${cacheHome}/zig/local";

    # Programming language data
    GOPATH        = "${dataHome}/go";
    CARGO_HOME    = "${dataHome}/rust/cargo";

    # Misc data
    MINETEST_USER_PATH = "${dataHome}/luanti";

    # Programming language config
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${configHome}/java";

    # History files
    HISTFILE       = "${stateHome}/sh/history";
    LESSHISTFILE   = "${stateHome}/less/history";
    PYTHON_HISTORY = "${stateHome}/python/history";

    # Misc cache files
    DVDCSS_CACHE  = "${cacheHome}/dvdcss";
    XCOMPOSECACHE = "${cacheHome}/X11/xcompose";

    # Misc data files
    GNUPGHOME = "${dataHome}/gnupg";
  };
}
