#!/bin/bash

buildDir="build"
launchPadDataDir="launchpad"
srcDir="src"
fileHooksPath="src/lua/CommunityBalanceMod_FileHooks.lua"
revisionVariable="g_communityBalanceModRevision"
betaRevisionVariable="g_communityBalanceModBeta"
modName="CommunityBalanceMod"
licenseFile="LICENSE"
readMeFile="README.md"

test $1 || { echo "Usage: $0 ns2_install_path"; exit 1; }
install_path="$1"
shift

# Attempt to extract revision numbers from Filehooks file
current_revision="$(cat $fileHooksPath | grep -oP "$revisionVariable = \K[0-9]+")"
current_beta_revision="$(cat $fileHooksPath | grep -oP "$betaRevisionVariable = \K[0-9]+")"

test -z "$current_revision" && { echo "Failed to lookup current revision"; exit 1; }
test -z "$current_beta_revision" && { echo "Failed to lookup current beta revision"; exit 1; }

revision_string="$current_revision"
test "$current_beta_revision" -eq 0 || revision_string="$revision_string beta $current_beta_revision"

echo "Creating build..."
echo
echo "$modName Revision: $revision_string"

# Check for outstanding commits
test -n "$(git status --porcelain)" && { echo "ERROR: You have outstanding commits, please commit before creating a build"; exit 1; }

# Build checks
/bin/bash check_for_outdated_vars.sh "$install_path"
test $? || { echo "ERROR: Build checks failed"; exit 1; }

# Re-create the build dir
test -d "$buildDir" && rm -rf "$buildDir"
mkdir $buildDir

# Create LaunchPad project skeleton
target="release"
if [ "$current_beta_revision" -ne 0 ]; then
    target="beta"
fi

cp $launchPadDataDir/$target/mod.settings $buildDir/mod.settings
cp $launchPadDataDir/$target/preview.jpg $buildDir/preview.jpg

mkdir $buildDir/source
cp -R $srcDir $buildDir/output
test -f $licenseFile && cp $licenseFile $buildDir/output/LICENSE
test -f $readMeFile && cp $readMeFile $buildDir/output/README.md

sed -i "s/\%\%revision_string\%\%/$revision_string/g" $buildDir/mod.settings

echo "Build created"
