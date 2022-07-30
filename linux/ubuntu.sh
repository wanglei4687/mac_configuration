#!/bin/bash

set -e

version="1.18.4"
goarch="amd64"
goos="linux"
workspace="$HOME/go"
name=wanglei4687
email="wanglei4687@gmail.com"

# Update pkg
sudo apt -y update
sudo apt -y upgrade

# Install develop tools
sudo apt install -y gcc make build-essential cmake protobuf-compiler curl openssl libssl-dev libcurl4-openssl-dev pkg-config postgresql-client tmux lld \
 curl ca-certificates gnupg git mysql-client

# Add source
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

## git setting
git config --global user.email $email
git config --global user.name $name

# Install pg client
sudo apt update
sudo apt install postgresql-client-11
pg_basebackup -V

# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source ~/.cargo/env

cat > ~/.cargo/config <<EOF
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

replace-with = 'tuna'
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

#replace-with = 'ustc'
#[source.ustc]
#registry = "git://mirrors.ustc.edu.cn/crates.io-index"

[net]
git-fetch-with-cli = true
EOF

# go
wget_output=$(wget -O /tmp/go.$version.tar.gz https://storage.googleapis.com/golang/go$version.$goos-$goarch.tar.gz)
if [ $? -ne 0 ]; then
	echo "unable to install go $version"
	echo $wget_output
	exit 1
fi

tar_output=$(sudo tar -C /usr/local -xzf /tmp/go.$version.tar.gz)
if [ $? -ne 0 ]; then
	echo "unable to install go $version"
	echo $tar_output
	exit 1
fi

# go was successfully downloaded and installed; set up the workspace
mkdir -p "$workspace"
sudo sh -c  'echo export "GOPATH=$workspace" >> "$HOME/.bashrc"'
sudo sh -c 'echo export "PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> "$HOME/.bashrc"'
source "$HOME/.bashrc"

go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct


echo "complete: go $version installed"
echo "  GOPATH=$workspace"