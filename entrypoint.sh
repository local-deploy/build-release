#!/bin/bash

set -e

PROJECT_ROOT="/go/src/github.com/${GITHUB_REPOSITORY}"
BINARY_PATH="${GITHUB_WORKSPACE}/bin"
BINARY_NAME=$(basename "${GITHUB_REPOSITORY}")
RELEASE_TAG=$(basename "${GITHUB_REF}")
RELEASE_ASSET_NAME=${BINARY_NAME}-${RELEASE_TAG}
TARGETS="linux/amd64 linux/arm64 darwin/amd64 darwin/arm64"

echo "----> Setting up repository"
mkdir -p "${BINARY_PATH}"
mkdir -p "${PROJECT_ROOT}"
cp -a "${GITHUB_WORKSPACE}"/* "${PROJECT_ROOT}"/
cd "${PROJECT_ROOT}"

echo "----> Loading dependencies"
go mod download

echo "----> Building"
gox -osarch="${TARGETS}" -output="${BINARY_PATH}/${BINARY_NAME}_{{.OS}}_{{.Arch}}"

echo "----> Prepare config files"
cd "${GITHUB_WORKSPACE}"

echo "----> Compress files"
tar cvfz "${RELEASE_ASSET_NAME}".tar.gz config-files bin

echo "----> Build is complete"
