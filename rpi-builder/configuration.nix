{ config, lib, pkgs, ... }: {
  imports = [
    ../modules/xdg.nix
    ../modules/common.nix
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mgord9518 = {
    isNormalUser = true;
    description = "Mathew Gordon";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
  };

  networking.firewall.enable = true;
  environment.systemPackages = with pkgs; [];

  services = {
    # GNOME
    xserver.enable = true;
    xserver.desktopManager.gnome.enable = true;
    xserver.displayManager.gdm.enable = true;

    openssh.enable = true;
  };

  networking.networkmanager.enable = true;
}
