#!/usr/bin/env bash

# Install cask and language dependencies.

set -e

# Install emacs 26.3 from source to workaround broken 26.2 in fedora 30 and 31.
if [ "`uname`" != 'Darwin' ]; then
  pushd /tmp > /dev/null
    curl -LO http://mirrors.kernel.org/gnu/emacs/emacs-26.3.tar.gz
     tar xzf emacs-26.3.tar.gz
     cd emacs-26.3
     ./configure --prefix="${HOME}/emacs" --bindir="${HOME}/bin"
     make
     make install
  popd
  rm -rf /tmp/emacs-26.3*
  # Ensure emacs binary is in the path
  export PATH=${PATH}:${HOME}/bin
fi

# Install cask and language dependencies.

if [ ! -d ~/.cask ]; then
  curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python3
fi

pushd $(dirname $0) > /dev/null
  python3 ~/.cask/bin/cask install
popd > /dev/null

# Install gimme
if [ ! -f ~/bin/gimme ]; then
  curl -sL -o ~/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/5256888df1e749fdb6acabc8f9e07a52f05b9f28/gimme
  chmod +x ~/bin/gimme
fi

# Install golang dev tools
eval $(~/bin/gimme 1.13.1)
tool_urls=(
  'github.com/go-delve/delve/cmd/dlv'
  'github.com/kisielk/errcheck'
  'github.com/nsf/gocode'
  'github.com/rogpeppe/godef'
  'github.com/tools/godep'
  'golang.org/x/tools/cmd/cover'
  'golang.org/x/tools/cmd/gorename'
  'golang.org/x/tools/cmd/guru'
  'golang.org/x/tools/gopls'
)
export GOPATH=~/go
for tool_url in ${tool_urls[@]}; do
  go get -u "${tool_url}"
done
