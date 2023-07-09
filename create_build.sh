#!/bin/bash

build_dir="build"
script_name="$0"
build_target="$1"
build_type="$2"
shift 2

function usage() {
    echo
    echo "Usage: $script_name [build_target] [build_type]"
    echo
    echo "build_target - The target to build (e.g. dev, prod, etc.)"
    echo "build_type - The type of build to create. Can either be 'workshop' or 'launchpad'"
    echo
    exit 1
}

function move_src() {
    local content_dir="$1"
    shift
    
    mkdir "$build_dir/$content_dir"
    mkdir "$build_dir/$content_dir/configs"
    cp -r src/* "$build_dir/$content_dir/"
    cp "launchpad/$build_target/preview.jpg" "$build_dir/"
    cp configs/"$build_target"/*.json "$build_dir/$content_dir/configs/"

    for file in LICENSE README.md; do
        test -f "$file" && cp "$file" "$build_dir/$content_dir/"
    done
}

function main() {
    test "$build_target" || { echo "No build target provided!"; usage; exit 1; }
    test -d "launchpad/$build_target" || { echo "Invalid build target (no launchpad data)"; usage; exit 1; }
    test -d "configs/$build_target" || { echo "Invalid build target (no config data)"; usage; exit 1; }
    [[ "$build_type" == "launchpad" || "$build_type" == "workshop" ]] || { echo "Invalid build type"; usage; exit 1; }

    # Check for outstanding commits
    test -d .git && test -n "$(git status --porcelain)" && { echo "ERROR: You have outstanding commits, please commit before creating a build"; exit 1; }

    # Create build_dir (removing old directories if needed)
    test -d "$build_dir" && { 
        echo "Removing old build directory";
        rm -rf "$build_dir";
    }
    mkdir "$build_dir"

    # Load config
    local publish_id="$(jq -r .publish_id launchpad/$build_target/config.json)"
    local name="$(jq -r .name launchpad/$build_target/config.json)"
    local description="$(jq -r .description launchpad/$build_target/config.json | jq -r '.[]')"

    if [[ "$build_type" == "launchpad" ]]; then
        mkdir "$build_dir/source"
        move_src "output"
        cat > "$build_dir/mod.settings" <<EOF
name        = "$name"
source_dir  = "source/"
output_dir  = "output/"
description = [=[$description
]=]
image       = "preview.jpg"
tag_modtype = "Gameplay Tweak"
tag_support = "Must be run on Server"
publish_id = $publish_id
EOF
    fi

    if [[ "$build_type" == "workshop" ]]; then
        move_src "content"
        cat  > "$build_dir/workshopitem.vdf" <<EOF
"workshopitem"
{
	"appid"		"4920"
	"publishedfileid"		"$publish_id"
	"contentfolder"		"$(pwd)/$build_dir/content"
	"previewfile"		"$(pwd)/$build_dir/preview.jpg"
	"visibility"		"0"
	"title"		"$name"
	"description"		"$description"
	"changenote"		""
}

EOF
    fi

    echo "Build created in $build_dir"
}

main
