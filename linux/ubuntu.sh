#!/usr/bin/env bash

set -e

golang_version='1.21.0'
goarch='amd64'
goos='linux'
name='wanglei4687'
email='wanglei4687@gmail.com'
python_version='3.9'
pg_verison='15'

function base() {
    sudo apt -y update
    sudo apt -y upgrade
    # Install develop tools
    sudo apt install -y gcc make build-essential cmake protobuf-compiler curl openssl \
         libssl-dev libcurl4-openssl-dev pkg-config libprotoc-dev tmux lld libtool-bin \
         curl ca-certificates gnupg git
    # update hosts config
    # sudo bash -c "echo '199.232.68.133 raw.githubusercontent.com' >> /etc/hosts"
}

function install_python() {
    echo "python version: $python_version"
    sudo apt install software-properties-common -y
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt install python$python_version -y
    echo "++++++++++++++++++++++++++++++"
    echo "$(python3 --version)"
    echo "++++++++++++++++++++++++++++++"
}

function install_golang() {
    echo "golang version: $golang_version"
    wget -O $HOME/go.tar.gz https://dl.google.com/go/go$golang_version.$goos-$goarch.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $HOME/go.tar.gz
    sudo bash -c  "echo 'export PATH=$PATH:/usr/local/go/bin' > $HOME/.profile"
    source .profile

    # go proxy for China
    # https://goproxy.cn/
    go env -w GOPROXY=https://goproxy.cn,direct

    # clear
    sudo rm $HOME/go.tar.gz

    # env info
    echo "++++++++++++++++++++++++++++++"
    echo $(go version)
    echo $(go env)
    echo "++++++++++++++++++++++++++++++"
}

function install_rust() {
    # rust
    echo 'export RUSTUP_DIST_SERVER="https://rsproxy.cn"' >> .bashrc
    echo 'export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"' >> bashrc
    sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
    source $HOME/.cargo/env

    # rust proxy for China
    # https://rsproxy.cn/
    cat > ~/.cargo/config << EOF
[source.crates-io]
replace-with = 'rsproxy-sparse'
[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"
[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"
[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"
[net]
git-fetch-with-cli = true
EOF

    # rust nightly
    rustup toolchain install nightly
    rustup component add rustc-dev --toolchain=nightly

    # env info
    echo "++++++++++++++++++++++++++++++"
    echo $(rustup --version)
    echo "------------------------------"
    echo $(rustup toolchain list)
    echo "------------------------------"
    echo $(cargo --version --verbose)
    echo "++++++++++++++++++++++++++++++"
}

function install_git() {
    ## git setting
    git config --global user.email $email
    git config --global user.name $name
    git config --global core.editor vim
    ssh-keygen -t ed25519 -f $HOME/.ssh/id_ed25519 -C $email -q -P ""


    echo "++++++++++++++++++++++++++++++"
    echo "ssh public key"
    echo "$(cat ~/.ssh/id_ed25519.pub)"
    echo "++++++++++++++++++++++++++++++"
}


function install_pgclient() {
    # Add pg source, apt-key deprecated
    # https://wiki.postgresql.org/wiki/Apt
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
    sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    sudo apt update
    sudo apt install postgresql-client-$pg_verison


    echo "++++++++++++++++++++++++++++++"
    echo "$(pg_basebackup -V)"
    echo "++++++++++++++++++++++++++++++"
}

function install_nodejs() {
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs


    echo "++++++++++++++++++++++++++++++"
    echo "nodejs version $(node --version)"
    echo "npm version $(npm --version)"
    echo "++++++++++++++++++++++++++++++"

}

function install_mysqlclient() {
    sudo apt install mysql-client


    echo "++++++++++++++++++++++++++++++"
    echo "$(mysql --version)"
    echo "++++++++++++++++++++++++++++++"
}

function env_clear() {
    sudo apt autoremove -y
}

function install() {
    echo "Start ...."
    base()
    install_git()
    install_rust()
    install_python()
    install_golang()
    install_nodejs()
    install_mysqlclient()
    install_pgclient()
    env_clear()
}


install()
exec '$@'
