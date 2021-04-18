#!/usr/bin/env bash
set -e

ask() {
  # http://djm.me/ask
  while true; do

    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # Ask the question
    read -p "$1 [$prompt] " REPLY

    # Default?
    if [ -z "$REPLY" ]; then
       REPLY=$default
    fi

    # Check if the reply is valid
    case "$REPLY" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac

  done
}

dir=`pwd`
if [ ! -e "${dir}/$(basename $0)" ]; then
  echo "Script not called from within repository directory. Aborting."
  exit 2
fi
dir="${dir}/.."

distro=`lsb_release -si`
if [ ! -f "dependencies/${distro}.sh" ]; then
  echo "Could not find file with dependencies for distro ${distro}. Aborting."
  exit 2
fi

ask "Install packages?" Y && bash ./dependencies/${distro}.sh

ask "Install symlink for .gitconfig?" Y && ln -sfn ${dir}/gitconfig ${HOME}/.gitconfig
ask "Install symlink for .bashrc?" Y && ln -sfn ${dir}/bashrc ${HOME}/.bashrc
ask "Install symlink for .bash_profile?" Y && ln -sfn ${dir}/bash_profile ${HOME}/.bash_profile
ask "Install symlink for .bash_logout?" Y && ln -sfn ${dir}/bash_logout ${HOME}/.bash_logout

ask "Install symlink for .config/bash?" Y && ln -sfn ${dir}/config/bash ${HOME}/.config/bash
ask "Install symlink for .config/compton?" Y && ln -sfn ${dir}/config/compton ${HOME}/.config/compton
ask "Install symlink for .config/i3?" Y && ln -sfn ${dir}/config/i3 ${HOME}/.config/i3
ask "Install symlink for .config/nvim?" Y && ln -sfn ${dir}/config/nvim ${HOME}/.config/nvim
ask "Install symlink for .config/polybar?" Y && ln -sfn ${dir}/config/polybar ${HOME}/.config/polybar
ask "Install symlink for .config/rofi?" Y && ln -sfn ${dir}/config/rofi ${HOME}/.config/rofi
ask "Install symlink for .config/termite?" Y && ln -sfn ${dir}/config/termite ${HOME}/.config/termite
ask "Install symlink for .config/wallpaper?" Y && ln -sfn ${dir}/config/wallpaper ${HOME}/.config/wallpaper