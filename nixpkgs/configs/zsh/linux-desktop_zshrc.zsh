typeset -U path
path=($HOME/.config/emacs/bin
      $HOME/.poetry/bin
      $HOME/.cargo/bin
      $HOME/.local/bin
      $HOME/n/bin
      $HOME/.ghcup/bin
      $HOME/.local/share/julia/bin
      $path)

export TERMINAL="alacritty"
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64
export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
conda () {
__conda_setup="$('$HOME/.local/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/.local/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/.local/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/.local/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
conda "$@"
}

snvim() {
      $HOME/.local/nvim/bin/nvim -u ~/.config/nvim/init_test.lua $@
}

home-upgrade () {
  nix flake update $HOME/.config/nixpkgs
  home-manager switch --flake "/home/michael/.config/nixpkgs#linux-desktop"
  # (( $+commands[doom] )) && doom -y upgrade
}

home-switch () {
  home-manager switch --flake "/home/michael/.config/nixpkgs#linux-desktop"
}
