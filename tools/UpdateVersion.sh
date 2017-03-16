#!/bin/bash
set -e

#------------------------------------------------------------
# Check if there is a new shiny server version

version=$(curl -s https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION)

if [[ -z "${version}" ]]; then
  echo "No Shiny Server version number found"
  exit 1
fi

echo "Current version is ${version}"
if [[ -n $(git tag -l "v${version}") ]]; then
  echo "Tag v${version} already exists, not doing anything"
  exit 2
fi

#------------------------------------------------------------
# Update Dockerfile to build the new version

echo "Updating Dockerfile to version ${version}"
regexp='s/\(shiny-server-\)[0-9][0-9.]\+\(-amd64.deb"\)/\1'"${version}"'\2/g'
sed -i -e "${regexp}" Dockerfile
regexp='s/\(\/shiny:\)[0-9][0-9.]\+/\1'"${version}"'/g'
sed -i -e "${regexp}" README.md

#------------------------------------------------------------
# Commit, tag and push the update

echo "Tagging as v${version} and pushing"
git commit -a -m "Bump Shiny Server version to ${version}"
git tag -a -m "Shiny Server version ${version}" "v${version}"
git push --tags

# The push will trigger Docker Hub to automatically build the new tag

echo "Done."
# end
