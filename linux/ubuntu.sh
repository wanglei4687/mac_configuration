#!/bin/bash

set -e

version="1.18.4"
goarch="amd64"
goos="linux"
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
source $HOME/.cargo/env

cat > $HOME/.cargo/config <<EOF
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
sudo wget -O /tmp/go.tar.gz https://dl.google.com/go/go$version.$goos-$goarch.tar.gz 
sudo rm -rf /usr/local/go && sudo tar -xzf /tmp/go.tar.gz

sudo mkdir .go .go/bin
sudo mv /tmp/go/bin $HOME/.go/bin

cat $HOME/.go/env << EOF
case ":${PATH}:" in
    *:"$HOME/.go/bin":*)
        ;;
    *)
        export PATH="$HOME/.go/bin:$PATH"
        ;;
esac
EOF

source $HOME/.go/env

go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct

echo "------------------------------"
echo  $(rustup --verison)
echo "------------------------------"
echo $(rustup toolchain list)
echo "------------------------------"
echo $(cargo --version --verbose)
echo "------------------------------"
echo $(go version)