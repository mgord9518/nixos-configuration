{ inputs, flakes, config, systemConfig, pkgs, user, ... }: rec {
  home.username = user;
  home.homeDirectory = systemConfig.users.users.${user}.home;

  imports = [
    ../../modules/home/firefox-tweaks.nix
  ];

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    settings.use-xdg-base-directories = true;
  };

  xdg = {
    enable = true;

    cacheHome  = config.home.homeDirectory + "/.local/cache";
    configHome = config.home.homeDirectory + "/.local/config";
  };

  home.file."${xdg.configHome}/monitors.xml".source = ./monitors.xml;

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Mathew Gordon";
    userEmail = "mgord9518@gmail.com";
  };

  dconf.settings = {
    "org/gnome/Console" = { shell = [ "${flakes.mgord9518-nur.mist}/bin/mist" ]; };
  };

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.dash-to-dock; }
      { package = pkgs.gnomeExtensions.tiling-assistant; }
      { package = pkgs.gnomeExtensions.system-monitor; }
      { package = pkgs.gnomeExtensions.blur-my-shell; }
    ];
  };

  home.stateVersion = "23.05";
}
