{ pkgs, modulesPath, ... }: {
  imports = [
    ./configuration.nix
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
  ];
}
