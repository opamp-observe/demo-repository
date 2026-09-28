#!/usr/bin/env sh
# Licensed under the Apache License, Version 2.0.
# Copyright 2026 mp3monster.org

set -eu

print_usage() {
    # Prints command usage for operators who need the required core path.
    printf '%s\n' "Usage: $0 <opamp-core-root> [opamp-demos-root]"
    printf '%s\n' ""
    printf '%s\n' "Copies cli/ and demos/ from opamp-demos into an installed opamp-core root."
}

absolute_path() {
    # Resolves a directory path to an absolute path after validating it exists.
    raw_path=$1
    if [ ! -d "$raw_path" ]; then
        printf '%s\n' "Directory not found: $raw_path" >&2
        exit 1
    fi
    (cd "$raw_path" && pwd)
}

assert_overlay_source() {
    # Verifies that the source root contains the expected overlay artifacts.
    resolved_source_root=$1
    profile_path="$resolved_source_root/cli/config/demo_consumer_profiles.full_multi_agent.json"
    demo_readme_path="$resolved_source_root/demos/full_multi_agent/readme.md"

    if [ ! -f "$profile_path" ]; then
        printf '%s\n' "Overlay source is missing required path: $profile_path" >&2
        exit 1
    fi

    if [ ! -f "$demo_readme_path" ]; then
        printf '%s\n' "Overlay source is missing required path: $demo_readme_path" >&2
        exit 1
    fi
}

copy_overlay_folder() {
    # Merges one top-level overlay folder into the installed core deployment.
    resolved_source_root=$1
    resolved_core_root=$2
    folder_name=$3
    source_path="$resolved_source_root/$folder_name"
    target_path="$resolved_core_root/$folder_name"

    mkdir -p "$target_path"
    if command -v rsync >/dev/null 2>&1; then
        rsync -a "$source_path/" "$target_path/"
    else
        cp -R "$source_path/." "$target_path/"
    fi
}

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    print_usage
    exit 1
fi

core_root=$1
if [ "$#" -eq 2 ]; then
    source_root=$2
else
    script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    source_root=$(CDPATH= cd -- "$script_directory/.." && pwd)
fi

resolved_core_root=$(absolute_path "$core_root")
resolved_source_root=$(absolute_path "$source_root")

assert_overlay_source "$resolved_source_root"

copy_overlay_folder "$resolved_source_root" "$resolved_core_root" "cli"
copy_overlay_folder "$resolved_source_root" "$resolved_core_root" "demos"

printf '%s\n' "OpAMP demo overlay copied to: $resolved_core_root"
printf '%s\n' "Select the profile with:"
printf '%s\n' "  opamp-cli cli-config change-config"
printf '%s\n' "Profile path:"
printf '%s\n' "  cli/config/demo_consumer_profiles.full_multi_agent.json"
