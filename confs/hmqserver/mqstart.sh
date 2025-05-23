#!/usr/bin/env bash
HFS=/opt/hfs20.5
pushd $HFS
source houdini_setup
popd
exec $HFS/bin/mqserver -s -p 37801 -n 1024 -l 3 -w 37800 1024 result