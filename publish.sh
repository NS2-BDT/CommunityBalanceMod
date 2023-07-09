#!/bin/bash

build_dir="build"

test -d "$build_dir" || { echo "No build; run ./create_build.sh"; exit 1; }

steamcmd +login NS2BDT +workshop_build_item $(pwd)/build/workshopitem.vdf +quit || {
    echo "Workshop publish failed";
    exit 1;
}

rm -rf "$build_dir"

echo
echo "Publish successful"
