let
  lock = value: {
    Value = value;
    Status = "locked";
  };

  force_install_extension = url: {
    install_url = url;
    installation_mode = "force_installed";
  };

  addon_root = "https://addons.mozilla.org/firefox/downloads";
in {
  programs.firefox = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;

      Preferences = {
        "browser.newtabpage.activity-stream.system.showSponsored"  = lock false;
        "browser.newtabpage.activity-stream.showSponsored"         = lock false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock false;
      };

      ExtensionSettings = {
        "*".installation_mode = "blocked"; # Blocks all addons except the ones specified below
    
        "uBlock0@raymondhill.net" =
          force_install_extension "${addon_root}/latest/ublock-origin/latest.xpi";
    
        "sponsorBlocker@ajay.app" =
          force_install_extension "${addon_root}/file/4451103/sponsorblock-5.11.8.xpi";
      };
    };
  };
}
