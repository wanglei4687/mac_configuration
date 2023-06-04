#!/bin/bash

set -e

version="1.20.4"
goarch="amd64"
goos="linux"
name=wanglei4687
email="wanglei4687@gmail.com"
python_version="3.8"

# Update pkg
sudo apt -y update
sudo apt -y upgrade

# Install develop tools
sudo apt install -y gcc make build-essential cmake protobuf-compiler curl openssl libssl-dev libcurl4-openssl-dev pkg-config postgresql-client tmux lld \
 curl ca-certificates gnupg git mysql-client

# update hosts config
sudo bash -c "echo '199.232.68.133 raw.githubusercontent.com' >> /etc/hosts"

# python3
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
echo "python version: $python_version"
sudo apt install python$python_version -y

# nodejs
sudo apt install nodejs npm

# Add source
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

## git setting
git config --global user.email $email
git config --global user.name $name
 ssh-keygen -t ed25519 -f $HOME/.ssh/id_ed25519 -C $email -q -P ""

# Install pg client
sudo apt update
sudo apt install postgresql-client-11
pg_basebackup -V

# rust
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

# config rust proxy, default sjtu mirror
curl -o ~/.cargo/config https://raw.githubusercontent.com/wanglei4687/os_config/main/cargo/config

# go
wget -O $HOME/go.tar.gz https://dl.google.com/go/go$version.$goos-$goarch.tar.gz 
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $HOME/go.tar.gz

sudo bash -c  "echo 'export PATH=$PATH:/usr/local/go/bin' > $HOME/.profile"


go env -w GOPROXY=https://goproxy.cn,direct


echo "------------------------------"
echo  $(rustup --version)
echo "------------------------------"
echo $(rustup toolchain list)
echo "------------------------------"
echo $(cargo --version --verbose)
echo "------------------------------"
echo $(go version)
echo "------------------------------"
echo "nodejs version $(node --version)"
echo "npm version $(npm --version)"
echo "------------------------------"
echo "$(python3 --version)"

sudo rm -rf $HOME/go.tar.gz

# clear
sudo apt autoremove -y