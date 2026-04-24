export PATH="$PATH:/bin/Swiftpoint X1 Control Panel 3.0.7.20"

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='lsd'
alias ll='ls -lAh'
alias vim='nvim'
alias c='reset && fastfetch'
alias ..='cd ..'
alias ...='cd ..;cd ..'
alias md='mkdir -p'
alias ip='ip --color'
alias clear='c'

ZVM_LINE_INIT_WIDGET="zle-line-init"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

zinit ice depth=1; zinit light jeffreytse/zsh-vi-mode
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

# attach if tmux session exists
if [ -z "$TMUX" ]; then
    if ! tmux has-session -t main 2>/dev/null; then
        # Create the session if it doesn't exist
        exec tmux new-session -s main
    elif ! tmux list-clients -t main 2>/dev/null | grep -q .; then
        # Attach only if no clients are attached
        exec tmux attach-session -t main
    fi
fi


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
#

export MAMBA_EXE="$HOME/miniforge3/bin/mamba"
export MAMBA_ROOT_PREFIX="$HOME/miniforge3"

_mamba_lazy_init() {
  unfunction _mamba_lazy_init
  unalias mamba conda 2>/dev/null
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
  if [ $? -eq 0 ]; then eval "$__mamba_setup"; fi
  unset __mamba_setup
}

alias mamba='_mamba_lazy_init && mamba'
alias conda='_mamba_lazy_init && conda'


# direnv hook (lädt .envrc beim cd)
eval "$(direnv hook zsh)"



# conda_lazy_init() {
#   unfunction conda_lazy_init  # sich selbst entfernen nach erstem Aufruf
#   unalias conda mamba 2>/dev/null
#   __conda_setup="$("$HOME/miniforge3/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)"
#   if [ $? -eq 0 ]; then eval "$__conda_setup"; fi
#   unset __conda_setup
# }
#
# export MAMBA_EXE="$HOME/miniforge3/bin/mamba"
# export MAMBA_ROOT_PREFIX="$HOME/miniforge3"
#
# _mamba_lazy_init() {
#   unfunction _mamba_lazy_init
#   unalias mamba conda 2>/dev/null
#   __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
#   if [ $? -eq 0 ]; then
#     eval "$__mamba_setup"
#   else
#     alias mamba="$MAMBA_EXE"
#   fi
#   unset __mamba_setup
# }
#
#
# _conda_auto_activate() {
#   local env_file=""
#   # environment.yml oder environment.yaml suchen
#   [[ -f environment.yml  ]] && env_file="environment.yml"
#   [[ -f environment.yaml ]] && env_file="environment.yaml"
#
#   if [[ -n "$env_file" ]]; then
#     local env_name
#     env_name=$(grep '^name:' "$env_file" | awk '{print $2}')
#     if [[ -n "$env_name" && "$CONDA_DEFAULT_ENV" != "$env_name" ]]; then
#       _mamba_lazy_init
#       mamba activate "$env_name"
#       _CONDA_AUTO_ROOT="$(pwd)"
#     fi
#   # Verzeichnis ohne env-Datei: deaktivieren falls wir das Root verlassen haben
#   elif [[ -n "$_CONDA_AUTO_ROOT" ]] && [[ "$(pwd)" != "$_CONDA_AUTO_ROOT"* ]]; then
#     mamba deactivate
#     _CONDA_AUTO_ROOT=""
#   fi
# }
#
# alias conda='_mamba_lazy_init && conda'
# alias mamba='_mamba_lazy_init && mamba'
#
# # zsh-Hook: wird bei jedem cd aufgerufen
# autoload -Uz add-zsh-hook
# add-zsh-hook chpwd _conda_auto_activate
#
# __conda_setup="$('/home/Horro/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/Horro/miniforge3/etc/profile.d/conda.sh" ]; then
#         . "/home/Horro/miniforge3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/Horro/miniforge3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
#

# <<< conda initialize <<<


# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
# export MAMBA_EXE='/home/Horro/miniforge3/bin/mamba';
# export MAMBA_ROOT_PREFIX='/home/Horro/miniforge3';
# __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__mamba_setup"
# else
#     alias mamba="$MAMBA_EXE"  # Fallback on help from mamba activate
# fi
# unset __mamba_setup
# <<< mamba initialize <<<

export ROCM_PATH=/opt/rocm
export HSA_OVERRIDE_GFX_VERSION=10.3.0

clear

