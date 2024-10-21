{ config, pkgs, ... }:

{
  imports = [
    # Modular config
    ./modules/servicemenus.nix
  ];

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    package = pkgs.nix;
  };

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "mgord9518";
  home.homeDirectory = "/home/mgord9518";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    (pkgs.writeShellScriptBin "mullvad-status" ''
      status=$(mullvad status | head -n1)

      if [ $(cut -d' ' -f1 <<< "$status") = "Connected" ]; then
          #echo -n "" $(cut -d' ' -f3- <<< "$status")
          echo -n ""
          connected=1
      else
          #echo -n " Disconnected"
          echo -n ""
      fi

      if [ "$1" = "toggle" ]; then
          if [ $connected ]; then
              mullvad disconnect
          else
              mullvad connect
          fi
      fi
    '')

    (pkgs.writeShellScriptBin "fzf-config" ''
      configs="hypr/hyprland.conf
      waybar/config.json
      waybar/window_title.json
      waybar/style.css"

      get_selection() {
        for p in $PATH; do
            echo -n "$configs"
        done | fzf
      }

      if selection=$( get_selection ); then
          "$EDITOR" "$HOME/.config/$selection"
      fi
    '')

    (pkgs.writeShellScriptBin "vol-display" ''
    device="@DEFAULT_AUDIO_SINK@"

    if [ $1 ]; then
        wpctl set-volume -l 1.44 "$device" "$1"
    fi

    volume=$(wpctl get-volume "$device" | cut -d' ' -f2 | tr -d '.')
    volume=$((10#$volume))

    dunst_string="volume
    [ "

    for i in $(seq 48); do
        [ $((i % 2)) -eq 0 ] && continue

        if [ "$volume" -ge $(((i + 1) * 3)) ]; then
            dunst_string="''${dunst_string}:"
        elif [ "$volume" -ge $(((i) * 3)) ]; then
            dunst_string="''${dunst_string}."
        else
            dunst_string="''${dunst_string} "
        fi
    done

    dunst_string="$dunst_string ]"

    dunstify -r 69 "$dunst_string"
    '')

    (pkgs.writeShellScriptBin "brightness-display" ''
    if [ $1 ]; then
        brightnessctl s "$1"
    fi

    brightness_max=$(brightnessctl m)
    brightness_step=$(($brightness_max / 48))

    brightness=$(brightnessctl g)
    brightness=$(($brightness / $brightness_step))

    dunst_string="brightness
    [ "

    for i in $(seq 48); do
        [ $((i % 2)) -eq 1 ] && continue

        if [ "$brightness" -ge $((i)) ]; then
            dunst_string="''${dunst_string}:"
        elif [ "$brightness" -ge $((i - 1)) ]; then
            dunst_string="''${dunst_string}."
        else
            dunst_string="''${dunst_string} "
        fi
    done

    dunst_string="$dunst_string ]"

    dunstify -r 69 "$dunst_string"
    '')

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

#    "Convert Image2" = {
#      mimetypes = [ "image/*" ];
#      actions = {
#        "Convert to JXL (lossless)" = {
#          icon = "video";
#          exec = ''filename="%f"; ${pkgs.libjxl}/bin/cjxl -q 100 "%f" "''${filename%.*}.jxl"'';
#        };
#      };
#    };
  };


  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mgord9518/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    
    plugins = [
    ];

    extraPackages = with pkgs; [
      #xclip
      wl-clipboard

      zls
    ];

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.zsh = {
    enable = true;

    initExtra = ''
      export PROMPT='[ %(!.%F{red}.%F{cyan})%n %F{reset}@ %F{yellow}%m %F{reset}]%# '
      export RPROMPT='[ %F{blue}%~ %F{reset}: %F{magenta}%? %F{reset}]'
    '';

    history.size = 10000;
    history.path = "${config.xdg.cacheHome}/zsh/history";
  };

  programs.git = {
    enable = true;
  };

  home.stateVersion = "23.05"; # Please read the comment before changing.
}
