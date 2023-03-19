#!/bin/bash

. scripts/shared_funcs.sh

build_dir="$(load_config_entry build_dir)"
launchpad_data_dir="$(load_config_entry launchpad_data_dir)"
src_dir="$(load_config_entry src_dir)"
beta_revision_variable="$(load_config_entry revision_variable)"
mod_name="$(load_config_entry mod_name)"
license_file="$(load_config_entry license_file)"
readme_file="$(load_config_entry readme_file)"

install_path="$(get_ns2_install_path)"

revision="$(get_revision)"
beta_revision="$(get_beta_revision)"
revision_string="$(get_revision_string "$revision" "$beta_revision")"

echo "Creating build..."
echo
echo "$mod_name Revision: $revision_string"

# Check for outstanding commits
test -n "$(git status --porcelain)" && { echo "ERROR: You have outstanding commits, please commit before creating a build"; exit 1; }

# Build checks
/bin/bash check_for_outdated_vars.sh "$install_path"
test $? || { echo "ERROR: Build checks failed"; exit 1; }

# Re-create the build dir
test -d "$build_dir" && rm -rf "$build_dir"
mkdir $build_dir

# Create LaunchPad project skeleton
target="release"
if [ "$beta_revision" -ne 0 ]; then
    target="beta"
fi

cp $launchpad_data_dir/$target/mod.settings $build_dir/mod.settings
cp $launchpad_data_dir/$target/preview.jpg $build_dir/preview.jpg

mkdir $build_dir/source
cp -R $src_dir $build_dir/output
test -f $license_file && cp $license_file $build_dir/output/LICENSE
test -f $readme_file && cp $readme_file $build_dir/output/README.md

sed -i "s/\%\%revision_string\%\%/$revision_string/g" $build_dir/mod.settings

echo "Build created"
