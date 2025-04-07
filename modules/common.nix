{ pkgs, environment, ... }: {
  nix.settings = {
    experimental-features = [ 
      "nix-command"
      "flakes"
    ];

    use-xdg-base-directories = true;
    auto-optimise-store = true;
  };

  programs = {
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 5";
      flake = "/home/mgord9518/Nix";
    };

    nvf = {
      enable = true;
      settings.vim = {
        useSystemClipboard = true;
        undoFile.enable    = true;
        searchCase         = "ignore";

        theme = {
          enable = true;
          name   = "gruvbox";
          style  = "dark";
        };

        languages = {
          nix.enable    = true;
          zig.enable    = true;
          clang.enable  = true;
          nim.enable    = true;
          rust.enable   = true;
          go.enable     = true;
          python.enable = true;
        };

        options = {
          shiftwidth = 4;
        };

        luaConfigPost = ''
          -- Restore cursor position
          vim.api.nvim_create_autocmd({ "BufReadPost" }, {
              pattern = { "*" },
              callback = function()
                  vim.api.nvim_exec('silent! normal! g`"zv', false)
              end,
          })
        '';
      };
    };
  };

  services = {
    pulseaudio.enable = false;
    flatpak.enable = true;

    mullvad-vpn = {
      enable  = true;
      package = pkgs.mullvad-vpn;
    };

    xserver = {
      xkb.layout  = "us";
      xkb.variant = "";
      autorun     = false;

      # Configure keymap
      xkb = {
        options = "caps:swapescape";
      };
    };

    # Pipewire for sound
    pipewire = {
      enable            = true;
      alsa.enable       = true;
      alsa.support32Bit = true;
      pulse.enable      = true;
    };

    #thermald.enable = true;
  };

  # Apply X11 keymap to Linux TTY
  console.useXkbConfig = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;

  hardware = {
    graphics = {
      enable = true;
      #enable32Bit = true;
    };

    bluetooth.enable = true;
  };

  security.sudo.package = pkgs.sudo.override { withInsults = true; };

  environment.sessionVariables = {
    EDITOR  = "nvim";

    # Keyboard options
    # Swap ESC and CAPS LOCK
    XKB_DEFAULT_OPTIONS = "caps:swapescape";

    TERM = "xterm-256color";
  };

  environment.systemPackages = with pkgs; [
    neovim
    wget
    xxd
    file
    git
    unzip
    wl-clipboard
    dash
    tmux
    libsecret
  ];

  # Set your time zone.
  time.timeZone = "America/Boise";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };
}
