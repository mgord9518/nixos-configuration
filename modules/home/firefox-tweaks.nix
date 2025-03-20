{
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default profile";
      isDefault = true;

      settings = {
        "sidebar.verticalTabs" = true;

        # Firefox scrolls too fast by default on Linux
        "mousewheel.default.delta_multiplier_y" = 50;
      };
    };
    policies = {
      ExtensionSettings = {
        "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4451103/sponsorblock-5.11.8.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };
}
