{ config, pkgs, ... }:

{
  imports = [
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

    extraConfig = ''
      " Enable Ctrl+Shift+C / Ctrl+Shift+V for copy and paste
      noremap <c-s-c> "+yy
      noremap <c-s-v> "+p
      
      set mouse=a
      set number relativenumber
      "set t_md=
      set cursorline
      
      set nowrap!
      set shiftwidth=4
      set tabstop=4
      set expandtab
      
      " Save undos across Neovim sessions
      set undodir=~/.cache/nvim/undodir
      set undofile
      set undolevels=10000
      set undoreload=10000
      
      " Save cursor position across Neovim sessions
      autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif 
      
      " Enable integration with system clipboard
      " Requires xclip for X11 or wl-clipboard for Wayland
      if has("unnamedplus")
          set clipboard=unnamedplus
      else
          set clipboard=unnamed
      endif
    '';
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
