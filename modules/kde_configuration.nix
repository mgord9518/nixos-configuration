{ config, pkgs, environment, ... }:

{
  programs = {
    kdeconnect.enable = true;
  };

  environment.sessionVariables = {
    GTK_THEME = "Breeze";
  };

  environment.systemPackages = with pkgs; [
    kdePackages.kdialog
    kdePackages.kimageformats
    kdePackages.breeze-gtk
    kdePackages.ark
    kdePackages.kcalc
  ];
}
