{ pkgs, ... }:
let
  sources = import ../../nix/sources.nix;
in
{
  imports = [
    ../../modules/alacritty.nix
    ../../modules/chat.nix
    ../../modules/cli.nix
    ../../modules/cuda.nix
    ../../modules/git.nix
    ../../modules/media.nix
    ../../modules/nix-utilities.nix
    ../../modules/nixos-desktop.nix
    ../../modules/python.nix
    ../../modules/ssh.nix
    ../../modules/languages.nix
    ../../modules/neovim.nix
    ../../modules/emacs.nix
  ];

  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";
  home.stateVersion = "20.09";

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    initExtraBeforeCompInit = builtins.readFile ../../configs/zsh/nixos_zshrc.zsh;
    initExtra = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/config/p10k-lean.zsh
    '';
  };

  services.lorri.enable = true;

}
