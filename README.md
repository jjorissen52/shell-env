This repository is setup to allow you to bootstrap some handy features into your shell environment using the `edit-env` script, a few functions, and some strategically placed files.

### Global Environment Configuration
```bash
edit-env rc # open for editing your rc file
edit-env env # open for editing a file dedicated to configuring your shell environment defined globally
edit-env func # open for editing a file dedicated to shell functions defined globally
edit-env alias # open for editing a file dedicated to shell aliases
edit-env git # open for editing global git configuration files
edit-env -h # help
```

### Per-Directory Environment Isolation
You can add a shell file with functions, variables, aliases, settings, etc, that will only apply to the current working directory. Example:
```bash
# open a file for editing named `.shell-functions`, the contents 
# of which will only be sourced to the current directory, 
# using the editor set to the environment variable EDITOR
edit-env -d func
# show the full path to the corresponding file
# /Users/jp.jorissen/.config/shell-env/Users/jp.jorissen/VsCode/shell-env/.shell-functions
edit-env -dl func
# source any relevant custom shell files from this directory
cd .
# re-construct your shell environment
reload-env
```

### Script Aliasing
Any executable script that you add to the directory `.shell-scripts` will have a corresponding bash function created, e.g., `edit-env.sh` can be called with `edit-env` from any bash-compatible shell:
```bash
edit-env -sx `edit-env.sh` # open for editing the globally-available `edit-env.sh` script
# open for editing a script which is only available in the current directory, callable with the function
# `hello-world`
edit-env -sdx `hello-world.sh`
# to load a corresponding bash function
reload-env
# call your script
hello-world
```

# Examples
Activate a Python environment any time you `cd` into this directory:
```bash
cat >> $(edit-env -ld env) << 'EOF'
source ./venv/bin/activate
EOF
```

Activate a specific `gcloud` configuration anytime you `cd` into this directory
```bash
# add check-activate to the bottom of your global functions file
cat >> $(edit-env -l func) << 'EOF'
check-activate() {
  test -z "${CONFIG_NAME}" && return 0
  test "$(cat ~/.config/gcloud/active_config)" == "${CONFIG_NAME}" && return 0
  if ! gcloud config configurations activate "${CONFIG_NAME}"; then
    err "Could not activate gcloud config ${CONFIG_NAME}. You can set a custom config name with the environment variable CONFIG_NAME."
    return $?
  fi
}
EOF
# have check-activate confirm your gcloud configuration when you enter this directory
cat >> $(edit-env -ld env) << 'EOF'
export CONFIG_NAME=my-config
check-activate
EOF

reload-env
```

Source a shared shell file defined in project any time you `cd` into the project directory
```bash
cat >> $(edit-env -ld env) << 'EOF'
source ./scripts/project-script.sh
EOF

reload-env
```


# Installation

```bash
git clone https://github.com/jjorissen52/shell-env.git ~/.config/shell-env
echo 'source ~/.config/shell-env/.bootstrap-env' >> ~/.bashrc
```

Or if you prefer, you can set a custom location.
```bash
export SHELL_ENV_DIRECTORY=~/.shellcfg
git clone https://github.com/jjorissen52/shell-env.git $SHELL_ENV_DIRECTORY
echo 'source $SHELL_ENV_DIRECTORY/.bootstrap-env' >> ~/.bashrc
```

To test it out first:
```bash
docker run -it bitnami/git bash -c "$(cat <<EOF
    useradd -m $(id -u -n) && \
    cd /home/$(id -u -n) && \
    mkdir .config && \
    git clone https://github.com/jjorissen52/shell-env.git .config/shell-env && \
    echo 'source ~/.config/shell-env/.bootstrap-env' > .bashrc && \
    chown -R $(id -u -n):$(id -u -n) /home/$(id -u -n) && \
    su -s /bin/bash $(id -u -n)
```