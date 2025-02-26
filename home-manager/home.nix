{ config, pkgs, ... }:

let
  garbageHome = config.home.homeDirectory + "/.local/garbage";
  librewolfHome = garbageHome + "/librewolf";
in {
  imports = [
    ./modules/servicemenus.nix
  ];

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    settings.use-xdg-base-directories = true;
    package = pkgs.nix;
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mgord9518";
  home.homeDirectory = "/home/mgord9518";

  xdg = {
    enable = true;

    #configHome = home.directory + "";
    cacheHome = config.home.homeDirectory + "/.local/cache";
    configHome = config.home.homeDirectory + "/.local/config";

    desktopEntries.librewolf = {
      icon = "${pkgs.librewolf}/share/icons/hicolor/128x128/apps/librewolf.png";
      name = "Librewolf";
      genericName = "Web Browser";
      exec = "env HOME=${librewolfHome} librewolf %U";
      terminal = false;
      categories = [ "Application" "Network" "WebBrowser" ];
      mimeType = [ "text/html" "text/xml" ];
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "convert-image";
      runtimeInputs = with pkgs; [
        # TODO: why does the script break with this
        #pkgs.xdg-utils
        pkgs.libjxl
        pkgs.imagemagick
      ];
      text = ''
        filename="$1"
        target_format="$2"
        quality="$3"

        new_filename="''${filename%.*}.$target_format"

        mimetype=$(xdg-mime query filetype "$filename")

        case "$mimetype" in
        'image/apng' | 'image/png' | 'image/jpeg' | 'image/x-exr' | 'image/gif' | 'image/x-portable-bitmap' | 'image/x-portable-graymap')
            if [ "$target_format" = "jxl" ]; then
                cjxl --quality 100 --effort 7 "$filename" "$new_filename"
            else
                magick convert -quality "$quality" "$filename" "$new_filename"
            fi
            ;;
        'image/'*)
            magick convert -quality "$quality" "$filename" "$new_filename"
            ;;
        esac
      ''
      ;
    })
  ];

  serviceMenus = {
    "Convert image to" = {
      mimetypes = [ "image/*" ];
      actions = {
        "JXL (lossless)" = {
          icon = "image";
          exec = "convert-image \"%f\" jxl 100";
        };
        "PNG" = {
          icon = "image";
          exec = "convert-image \"%f\" png 05";
        };
      };
    };
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
  };

  home.stateVersion = "23.05"; # Please read the comment before changing.
}
