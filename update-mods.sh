#!/usr/bin/env bash

dir="$(mktemp -d)"
modid="2077825026"

steamcmd +force_install_dir "$dir" +login anonymous +workshop_download_item 4920 "$modid" +logout +exit

moddir="$dir/steamapps/workshop/content/4920/$modid"

cp -r "$moddir/lua/HallucinationCloak" src/lua/
find "src/lua/HallucinationCloak" -type f -exec dos2unix {} \;

cp "$moddir/lua/entry/HallucinationCloak.entry" src/lua/entry/
dos2unix src/lua/entry/HallucinationCloak.entry

rm -rf "$dir"
echo "Done"
