let
  settings = {
    "sidebar.verticalTabs" = true;

    # Firefox scrolls too fast by default on Linux
    "mousewheel.default.delta_multiplier_y" = 50;

    # Enable userChrome.css
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  };
in {
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

      settings = settings;
    };
  };
}
