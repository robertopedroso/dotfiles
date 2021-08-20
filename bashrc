# ----------------------------------------------------------------------
# Prelude
# https://unix.stackexchange.com/questions/257571/why-does-bashrc-check-whether-the-current-shell-is-interactive
# ----------------------------------------------------------------------
case $- in
    *i*) ;;
      *) return;;
esac


# ----------------------------------------------------------------------
# Basic Config
# ----------------------------------------------------------------------
export PYENV_ROOT="$HOME/Code/pyenv"
export PATH="$HOME/.local/bin:/usr/local/bin:$PYENV_ROOT/bin:$HOME/Bin:$PATH"
export EDITOR="nvim"

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


# ----------------------------------------------------------------------
# Autoloaders
# ----------------------------------------------------------------------
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
[ -x "$(command -v pyenv)" ] && eval "$(pyenv init --path)"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
for f in $HOME/.config/bash/*; do source $f; done


# ----------------------------------------------------------------------
# Prompt
# https://github.com/arcticicestudio/igloo/blob/master/snowblocks/bash/core/prompt
# ----------------------------------------------------------------------
c_gray='\e[01;30m'
c_yellow='\e[0;33m'
c_blue='\e[0;34m'
c_cyan='\e[0;36m'
c_reset='\e[0m'

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=false
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=
GIT_PS1_DESCRIBE_STYLE="contains"
GIT_PS1_HIDE_IF_PWD_IGNORED=false

function compile_prompt () {
  PS1="${c_blue}\u ${c_reset}in ${c_yellow}\w ${c_cyan}$(__git_ps1 "(%s)") ${c_reset}\n$ "
}

PROMPT_COMMAND='compile_prompt'


# ----------------------------------------------------------------------
# Completions
# ----------------------------------------------------------------------
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# ----------------------------------------------------------------------
# Fancy LS Colors
# ----------------------------------------------------------------------
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi


# ----------------------------------------------------------------------
# Nifty Aliases
# ----------------------------------------------------------------------
alias foundry='cd $HOME/.local/share/FoundryVTT/Data/'


# ----------------------------------------------------------------------
# JOOR-Specific
# ----------------------------------------------------------------------
export AWS_PROFILE=joor-eks-preview


# ----------------------------------------------------------------------
# Load Nix
# ----------------------------------------------------------------------
if [ -e /home/rpedroso/.nix-profile/etc/profile.d/nix.sh ]; then
  . /home/rpedroso/.nix-profile/etc/profile.d/nix.sh;
fi # added by Nix installer
