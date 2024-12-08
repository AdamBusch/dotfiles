# Dotfiles

Dotfile configuration using [nix-darwin](https://github.com/LnL7/nix-darwin) and `home-manager`. 

# Install
1. Clone this repository to `~/dotfiles/`
1. Install `nix` using the [Determinate Systems](https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#determinate-nix-installer) installer for macOS
1. Run `nix run nix-darwin -- switch --flake ~/dotfiles#laptop` or `darwin-rebuild switch --refresh --flake ~/dotfiles#laptop` 

# Uninistall 
1. Uninistall nix-darwin using `darwin-uninstaller`
1. [Uninstall Nix](https://nix.dev/manual/nix/2.18/installation/uninstall)
