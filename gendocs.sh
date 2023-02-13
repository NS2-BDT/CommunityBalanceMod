#!/bin/bash

#TODO: Put these in a config
fileHooksPath="src/lua/LegacyBalanceMod_FileHooks.lua"
revisionVariable="g_legacyBalanceModRevision"
betaRevisionVariable="g_legacyBalanceModBeta"
modName="LegacyBalanceMod"
luaDir="src/lua"
modBalancePath="src/lua/LegacyBalanceMod/Globals/Balance.lua"

install_path="$1"
vanilla_build="$2"
shift 2

test -z "$install_path" || test -z "$vanilla_build" && { echo "Usage: $0 [ns2_install_path] [vanilla_build]"; exit 1; }

# Attempt to extract revision numbers from Filehooks file
current_revision="$(cat $fileHooksPath | grep -oP "$revisionVariable = \K[0-9]+")"
current_beta_revision="$(cat $fileHooksPath | grep -oP "$betaRevisionVariable = \K[0-9]+")"

test -z "$current_revision" && { echo "Failed to lookup current revision"; exit 1; }
test -z "$current_beta_revision" && { echo "Failed to lookup current beta revision"; exit 1; }

echo -n "Generating docs for $modName revision $current_revision"
test "$current_beta_revision" -eq 0 || echo -n " beta $current_beta_revision"
echo -en "\n"

# Generate docs
revision_args="$current_revision"
if [ "$current_beta_revision" -eq 0 ]; then
    revision_args="$revision_args $current_beta_revision"
fi

python3 scripts/docugen.py gen \
    "$luaDir" \
    "$install_path/ns2/lua" \
    "$modBalancePath" \
    "$install_path/ns2/lua/Balance.lua" \
    "$install_path/ns2/lua/BalanceHealth.lua" \
    "$install_path/ns2/lua/BalanceMisc.lua" \
    "$vanilla_build" \
    $revision_args

test "$?" || { echo "ERROR: Docugen returned a non-zero return-code"; exit 1; }
