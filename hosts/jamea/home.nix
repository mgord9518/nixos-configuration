{ inputs, flakes, config, pkgs, ... }: {
  home.username = "mgord9518";
  home.homeDirectory = "/home/mgord9518";

  imports = [];

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    settings.use-xdg-base-directories = true;
  };

  xdg = {
    enable = true;

    cacheHome = config.home.homeDirectory + "/.local/cache";
    configHome = config.home.homeDirectory + "/.local/config";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Mathew Gordon";
    userEmail = "mgord9518@gmail.com";
  };

  dconf.settings = {
    # Set shell to MIST
    "org/gnome/Console" = { shell = [ "${flakes.mgord9518-nur.mist}/bin/mist" ]; };

    "org/gnome/desktop/interface" = { gtk-theme    = "adw-gtk3-dark"; }; # GTK 3
    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
  };

  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      name = "Default profile";
      isDefault = true;

      userChrome = ''
        /* Fix line displaying on top of nav bar when using adw-gtk3 theme */
        #nav-bar {
          border-top: 0 !important;
          margin-right: 10 !important;
        }
      '';

      settings = {
        "sidebar.verticalTabs" = true;

        # Firefox scrolls too fast by default on Linux
        "mousewheel.default.delta_multiplier_y" = 200;

        # Enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
    };
  };

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.dash-to-dock; }
      { package = pkgs.gnomeExtensions.tiling-assistant; }
      { package = pkgs.gnomeExtensions.system-monitor; }
      { package = pkgs.gnomeExtensions.blur-my-shell; }
      { package = pkgs.gnomeExtensions.appindicator; }
    ];
  };

  home.stateVersion = "23.05";
}
