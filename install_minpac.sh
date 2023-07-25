#!/bin/sh

BASEDIR=$(cd $(dirname $0);pwd)/pack/minpac/opt/minpac
URL="https://github.com/k-takata/minpac.git"

if [ ! -d $BASEDIR ]; then
  mkdir -p $BASEDIR
fi

git clone $URL $BASEDIR
