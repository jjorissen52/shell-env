You can add this to your own environment with:

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