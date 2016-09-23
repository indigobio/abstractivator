#!/bin/bash -e

#This script is used during the release process. It is not intended to be ran manually.

VERSION="$1"
VERSION="${VERSION:?"must provide version as first parameter"}"
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd)"

updateVersion(){
    updateGemspec
    commitStagedFiles "Update version to ${VERSION}"
}

updateGemspec(){
    echo -e "\nUpdating version file"
    local versionPath="${SCRIPT_DIR}/lib/abstractivator/version.rb"
    sed -i 's:\(\s*VERSION\s*=\).*:\1 '"'${VERSION}'"':' "${versionPath}"
    stageFiles "${versionPath}"
}

updateLockfile(){
    echo -e "\nUpdating lockfile"
    bundle package --no-install > /dev/null
    rm -rf .bundle/ vendor/
    stageFiles "${SCRIPT_DIR}/Gemfile.lock"
}

stageFiles(){
    local files=( "$@" )
    git add "${files[@]}"
}

commitStagedFiles(){
    local msg="$1"
    if thereAreStagedFiles; then
        git commit -m "${msg}"
    else
        echo "No changes to commit"
    fi
}

thereAreStagedFiles(){
    git update-index -q --ignore-submodules --refresh
    ! git diff-index --cached --quiet HEAD --ignore-submodules --
}

updateVersion