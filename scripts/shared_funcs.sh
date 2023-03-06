#!/bin/bash

function load_config_entry() {
    local key="$1"
    shift

    entry="$(jq -e --raw-output ".$key" configs/config.json 2>/dev/null)"
    test $? -eq 0 || {
        echo "Failed to get config entry \"$key\"" >&2;
        kill -SIGPIPE "$$";
    }
    
    echo "$entry"
    return 0
}

function get_ns2_install_path() {
    path="$(jq -e --raw-output ".ns2_install_path" configs/local_config.json 2>/dev/null)"
    test $? -eq 0 || {
        echo "No NS2 install path set. Please configure in configs/local_config.json" >&2;
        kill -SIGPIPE "$$";
    }

    echo "$path"
    return 0
}

function __get_revision() {
    local var_key="$1"
    shift

    local filehooks_path="$(load_config_entry filehooks_path)"
    local revision_variable="$(load_config_entry "$var_key")"
    current_revision="$(cat $filehooks_path 2>/dev/null | grep -oP "$revision_variable = \K[0-9]+")"
    test -z "$current_revision" && {
        echo "Failed to lookup \"$revision_variable\" in \"$filehooks_path\"" >&2;
        kill -SIGPIPE "$$";
    }
    echo "$current_revision"
    return 0
}

function get_revision() {
    __get_revision revision_variable

    return 0
}

function get_beta_revision() {
    __get_revision beta_revision_variable

    return 0
}

function get_revision_string() {
    local rev="$1"
    local beta_rev="$2"
    shift 2

    local revision_string="$rev"
    test "$beta_rev" -eq 0 || revision_string="$rev beta $beta_rev"

    echo "$revision_string"
    return 0
}
