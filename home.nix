{ config, pkgs, ... }:

{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    zsh
    oh-my-zsh
    git
    fzf
    tmux
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size=12;
        normal.family="Fira Mono";
        bold.family="Fira Mono";
        italic.family="Fira Mono";
      };
      window = {
        padding.x = 10;
        padding.y = 10;
        opacity = 0.98;
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    history = {
      extended = true;
      save = 1000000000;
      ignoreDups = true;
      expireDuplicatesFirst = true;
      path = "$ZSH_CACHE/zsh_history";
    };
    syntaxHighlighting.enable = true;
    shellAliases = {
      ns = "nix run nix-darwin -- switch --flake ~/dotfiles#laptop";
    };
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
      extraConfig = ''
        ZSH_CACHE=$HOME/.cache/zsh
        ZSH_COMPDUMP="$ZSH_CACHE/.zcompdump-$SHORT_HOST-$ZSH_VERSION"
        mkdir -p "$(dirname "$ZSH_COMPDUMP")"
      '';
    };

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "6aced3f35def61c5edf9d790e945e8bb4fe7b305";
          sha256 = "EWMeslDgs/DWVaDdI9oAS46hfZtp4LHTRY8TclKTNK8=";
        };
      }
    ];

    profileExtra =''
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
       source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix
    '';
  };

  programs.git = {
    enable = true;
    userName = "AdamBusch";
    userEmail = "adamjbusch561@gmail.com";
    aliases = {
      bs = "!git branch | fzf --header='Checkout branch' --border=double --height=50% | sed 's/^\*//' | xargs -n 1 git checkout";
      bD = "!git branch | fzf -m --header='Delete branches, tab to select multiple' --border=double --height=50% | xargs git branch -d";
    };
    extraConfig = {
      oh-my-zsh = { hide-status = 1; };
      push = { autoSetupRemote = 1; };
    };
  };

}
