emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt. Should stay at the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable direnv
emulate zsh -c "$(direnv hook zsh)"

# Set dircolors
eval $( dircolors -b $HOME/.dircolors )

# Completion
autoload -U compinit 
compinit

# Completion options from zsh lovers
zstyle ':completion:*' menu select

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b' 

zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Host completion copied from grml
[[ -r ~/.ssh/config ]] && _ssh_config_hosts=(${${(s: :)${(ps:\t:)${${(@M)${(f)"$(<$HOME/.ssh/config)"}:#Host *}#Host }}}:#*[*?]*}) || _ssh_config_hosts=()
[[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()

hosts=(
	$(hostname)
	"$_ssh_config_hosts[@]"
	"$_ssh_hosts[@]"
	"$_etc_hosts[@]"
	localhost
       )

zstyle ':completion:*:hosts' hosts $hosts

# Glob settings
setopt extendedglob

# History
export HISTSIZE=2000
export HISTFILE="$HOME/.history" 
export SAVEHIST=$HISTSIZE
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history

# use emacs keybinding
bindkey -e

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[ShiftTab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[ShiftTab]}"  ]] && bindkey -- "${key[ShiftTab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start {
		echoti smkx
	}
	function zle_application_mode_stop {
		echoti rmkx
	}
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Control left/right for backward word/forward word
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

# Alt left/right for beginning-of-line/end-of-line
key[Alt-Left]="${terminfo[kLFT3]}"
key[Alt-Right]="${terminfo[kRIT3]}"

key[Alt-Left]="^[[1;3D"
key[Alt-Right]="^[[1;3C"

[[ -n "${key[Alt-Left]}"  ]] && bindkey -- "${key[Alt-Left]}"  beginning-of-line
[[ -n "${key[Alt-Right]}" ]] && bindkey -- "${key[Alt-Right]}" end-of-line

# Fish like history
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

# Rationalize dot (... -> ../..)
rationalise-dot() {
  if [[ $LBUFFER = *.. ]]; then
    LBUFFER+=/..
  else
    LBUFFER+=.
  fi
}

zle -N rationalise-dot
bindkey . rationalise-dot

# Colored output in man pages
man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}
# Edit current line with editor 
autoload edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Prompt configuration
source ~/.config/shell/powerlevel10k/powerlevel10k.zsh-theme
source ~/.config/shell/powerlevel10k/config/p10k-lean.zsh

#Aliases
upgrade () {
  git -C ~/.config/shell/z.lua pull 
  git -C ~/.config/shell/powerlevel10k pull
  doom -y upgrade
  rustup update
  cargo +nightly install sd
}

alias ls="ls --color=auto"
alias ll="exa -alh --sort=modified"
alias l="exa"


function start_container () {
  bash $HOME/.containers/launch_scripts/$1.sh
}

# Useful docker commands
# Can also append --filter="ancestor=tdw:bp-1.4.5a" to ignore running container
das () {
  docker kill $(docker ps -q)
}

dsh () {
  docker exec -i -t $1 /bin/bash
}

function _dsh(){
  containers=("${(@f)$(docker ps --format '{{.Names}}')}")
  compadd $containers
}

compdef _dsh dsh

# FZF
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Enable z.lua
eval "$(lua $HOME/.config/shell/z.lua/z.lua --init zsh)"


list-ec2 () {
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceType, State.Name, LaunchTime, PublicDnsName]' --output table
}
# Set environmental variables
export EDITOR="nvim"


# # >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# activate_conda() {
# __conda_setup="$('/home/michael/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/michael/miniconda3/etc/profile.d/conda.sh" ]; then
# 	. "/home/michael/miniconda3/etc/profile.d/conda.sh"
#     else
# 	export PATH="/home/michael/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# }
# <<< conda initialize <<<

. /home/michael/.nix-profile/etc/profile.d/nix.sh
