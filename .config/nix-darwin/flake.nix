{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, lib, config, ... }: {
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs;
        [
          mkalias
          gnupg
          tree
          imagemagick
          ffmpeg
          git
          ripgrep
          neovim
          gradle
          maven
          nodejs_22
          gh
          go
          rustup
          texliveFull
          uv
        ];

      homebrew = {
        enable = true;
        casks = [
          "font-fira-code-nerd-font"
          "font-jetbrains-mono"
          "google-cloud-sdk"
        ];
        # Prune unmentioned casks via "zap"
        # onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';

      # https://samasaur1.github.io/blog/jdks-on-nix-darwin
      system.activationScripts.extraActivation.text = ''
        ln -sf "${pkgs.jdk11}/zulu-11.jdk" "/Library/Java/JavaVirtualMachines/"
      '';

      system.defaults = {
        # dock.autohide = true;
        NSGlobalDomain.AppleICUForce24HourTime = false;
      };

      security.pam.services.sudo_local.touchIdAuth = true;

      # Determinate uses its own daemon to manage the Nix installation that
      # conflicts with nix-darwin’s native Nix management.
      #
      # To turn off nix-darwin’s management of the Nix installation, set:
      #
      #     nix.enable = false;
      #
      # This will allow you to use nix-darwin with Determinate. Some nix-darwin
      # functionality that relies on managing the Nix installation, like the
      # `nix.*` options to adjust Nix settings or configure a Linux builder,
      # will be unavailable.
      nix.enable = false;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # Apple Silicon only
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = "gideonoludeyi";

            autoMigrate = true;
          };
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."simple".pkgs;
  };
}
