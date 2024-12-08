{
  description = "Adam nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin"; 
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, nix-homebrew, home-manager }:
  let
    configuration = { pkgs, config, ... }: {
          
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [ 
        alacritty
        mkalias
        neovim
        tmux
      ];

      # Homebrew modules
      homebrew = {
        enable = true;
        casks = [
          "firefox"
        ];
      };

      # Setup users for home-manager before ./home.nix is run
      users.users.adam = {
        name = "adam";
        home = "/Users/adam";
      };

      # MacOS configuration
      system.defaults = {
        finder.FXPreferredViewStyle = "clmv";
      };

      # Fonts!
      fonts.packages = with pkgs; [
        fira-mono
      ];

      # Make aliases instead of symlinks for applications
      # Make alacritty install better, can be indexed by spotlight
      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
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

      # Auto upgrade
      services.nix-daemon.enable = true;
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      # Only using flakes, disable channels
      nix.channel.enable = false;
      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;
      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;
      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#laptop
    darwinConfigurations."laptop" = nix-darwin.lib.darwinSystem {
      modules = [
        
        configuration

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "adam";
          };
        }

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.adam = import ./home.nix;
        }

      ];
    };

    # Exposes package set
    darwinPackages = self.darwinConfigurations."laptop".pkgs;
  };
}
