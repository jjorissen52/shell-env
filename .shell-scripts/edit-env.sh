#!/usr/bin/env bash

set -e # exit on any error

filename-only() {
    local without_extension=${1%.*}
    echo "${without_extension##*/}" # strips path
}

usage() {
  # less either acts as `cat` or actually page the output, depending on TTY and terminal window size.
  less -XF <<EOF
DESCRIPTION
  Opens a shell-env file for editing. 


EXAMPLES
  # open .bashrc for editing
  $(filename-only $0) rc

  # create a new environment script called thing.sh which can be invoked in any TTY shell as thing
  # and make it executable
  $(filename-only $0) -s thing.sh 
  $(filename-only $0) -x thing.sh

  # create a script called thing2.sh which can be invoked in any TTY shell as thing2
  # any time you are in the current working directory
  $(filename-only $0) -sl thing2.sh


USAGE
  $(filename-only $0) [-l] [[-d] [-x] [-s] { script_names... }] [local|func|env|alias|docker|profile|rc|git|scripts|core|all]


FLAGS
  -l    show the paths of the indicated files

  -s    indicate that you will be editing a script

  -d    (only when -s is used) indicate that the script to be 
        edited is local to the current directory, e.g., that it should only 
        be loaded into a shell of the current working directory

  -x    (only when -s is used) give the indicated script executable permissions

  -h    show help
EOF
}

while getopts ":sdlx" o; do
    case "${o}" in
        s) 
            script="-s";;
        d) 
            is_local="-d";;
        l)
            show_path="-l";;
        x)
            exe="-x";;
        *)
            usage $0
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

add-file() {
  if [ -n "$files" ]; then
    files="$files
${1}"
  else
    files="${1}"
  fi
}

add-files() {
  while read file; do
    add-file "$file"
  done <<< "$@"
}


files=""
env_dir="$SHELL_ENV_DIRECTORY"
# these can be edited for the current dir
list="func env aliases docker"
if [ -n "$is_local" ]; then
  # set the env_dir to the current dir
  env_dir="${env_dir}${PWD}"
else
  # if it's not local we can add the rest of the core file list
  list="p rc git ${list}"
fi

for arg in $@; do
  case "$arg" in
    func|funcs|functions|shell-functions)
        add-file "${env_dir}/.shell-functions"
        ;;
    env|environment|shell-env)
        add-file "${env_dir}/.shell-env"
        ;;
    alias|aliases|shell-aliases)
        add-file "${env_dir}/.shell-aliases"
        ;;
    docker|shell-docker)
        add-file "${env_dir}/.shell-docker"
        ;;
    p|profile)
        add-file "${HOME}/.profile"
        ;;
    rc|bashrc)
        add-file "${HOME}/.bashrc"
        ;;
    git)
        for file in ${HOME}/.gitconfig ${SHELL_ENV_DIRECTORY}/.shell-git; do
          add-file "$file"
        done
        ;;
    core)
        for file in $list; do
          # recursive call to the script
          add-file "$($0 -l $is_local $file)"
        done
        ;;
    scripts)
        test -d ${env_dir}/.shell-scripts && \
          add-files "$(find ${env_dir}/.shell-scripts -maxdepth 1 -type f -exec echo {} \;)"
        ;;
    *)
        if [ -z "$script" ]; then
          usage
          exit 1
        fi
        add-file "${env_dir}/.shell-scripts/$arg"
        ;;
  esac
done

# make files executable if that was desired
if [ -n "$script" ] && [ -n "$exe" ]; then
  while read file; do
    mkdir -p "${file%/*}" && touch "${file}" && chmod +x "${file}"
  done <<< "$files"
fi

if [ -n "$show_path" ]; then
  # just show paths if that was desired
  while read file; do
    echo "$file"
  done <<< "$(echo "$files" | uniq)"
else
  # otherwise open the files
  "${EDITOR:-vim}" $files
fi
