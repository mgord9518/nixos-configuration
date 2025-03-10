{ config, pkgs, ... }:

let
  garbageHome = config.home.homeDirectory + "/.local/garbage";
  librewolfHome = garbageHome + "/librewolf";
in {
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

  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default profile";
      isDefault = true;

#      extensions = with firefox-addons; [
#        ublock-origin
#      ];

      settings = {
        "sidebar.verticalTabs" = true;
        "mousewheel.default.delta_multiplier_y" = 50;
      };
    };
    policies = {
      ExtensionSettings = {
        "*".installation_mode = "blocked"; # blocks all addons except the ones specified below
        # uBlock Origin:
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "SponsorBlock" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4424639/sponsorblock-5.11.5.xpi";
          installation_mode = "force_installed";
        };
      };
    };
  };

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.gsconnect; }
      { package = pkgs.gnomeExtensions.dash-to-dock; }
      { package = pkgs.gnomeExtensions.tiling-assistant; }
      { package = pkgs.gnomeExtensions.system-monitor; }
    ];
  };

  home.stateVersion = "23.05";
}
