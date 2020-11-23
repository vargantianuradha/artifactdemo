#!/bin/bash

set -e

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${THIS_SCRIPT_DIR}/.."

# Check if there's something uncommitted (don't release if there are files
#  not yet committed)
set +e
git_status="$(git status --porcelain)"
if [[ "${git_status}" != "" ]] ; then
	echo " [!] Uncommitted files found! Commit before release!"
	echo " (i) git_status: ${git_status}"
	exit 1
fi
set -e

current_version="$(cat ./version)"
echo "current_version: ${current_version}"

#
# How to roll-back?
#  * if you want to undo the last commit you can call:
#     $ git reset --hard HEAD~1
#  * to roll back to the remote state:
#     $ git reset --hard origin/[branch-name]
#

set -x

bumped_version=$(ruby -e "splits='${current_version}'.split('.');major=splits[0];minor=splits[1];puts \"#{major}.#{minor.to_i.next}\"")
echo " [i] bumped_version: ${bumped_version}"
echo "${bumped_version}" > ./version
git add ./version
git commit -m "v${bumped_version}"

git checkout prod
git merge master -m "Merge master into prod, release: v${bumped_version}"
git tag "${bumped_version}"

git checkout master
