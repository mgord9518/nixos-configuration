{ pkgs, flakes, ... }: {
  environment.systemPackages = with pkgs; [
    # System GUI utils
    gdm-settings
    mission-center

    # System CLI utils
    pv
    gnupg
    imagemagick

    # Extra CLI utils
    jq
    bubblewrap
    qemu

    # Programming languages
    go
    python3
    zig

    # Disk management
    exfatprogs
    popsicle

    adw-gtk3

    (pkgs.writeShellScriptBin "wget" ''
      ${pkgs.wget}/bin/wget --no-hsts
    '')
  ];

  environment.gnome.excludePackages = (with pkgs; [
    epiphany # Gnome web
    gnome-tour
    gnome-system-monitor
  ]);

  environment.sessionVariables = rec {
    CC  = "zig cc";
    CXX = "zig c++";
  };
}
