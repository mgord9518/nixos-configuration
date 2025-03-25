let
  settings = {
    "sidebar.verticalTabs" = true;

    # Firefox scrolls too fast by default on Linux
    "mousewheel.default.delta_multiplier_y" = 50;
  };
in {
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default profile";
      isDefault = true;

      settings = settings;
    };
  };
}
