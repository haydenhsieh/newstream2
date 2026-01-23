#! /bin/bash

dir=$(realpath $(dirname $BASH_SOURCE))
pushd $dir > /dev/null
./ns2.rb $*
popd > /dev/null
