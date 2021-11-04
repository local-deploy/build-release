#!/bin/bash

set -e

PROJECT_ROOT="/go/src/github.com/${GITHUB_REPOSITORY}"
BINARY_PATH="${GITHUB_WORKSPACE}/bin"
BINARY_NAME=$(basename "${GITHUB_REPOSITORY}")
RELEASE_TAG=$(basename "${GITHUB_REF}")
RELEASE_ASSET_NAME=${BINARY_NAME}-${RELEASE_TAG}
TARGETS=("darwin/amd64" "linux/amd64")

echo "----> Setting up repository"
mkdir -p "${BINARY_PATH}"
mkdir -p "${PROJECT_ROOT}"
cp -a "${GITHUB_WORKSPACE}"/* "${PROJECT_ROOT}"/
cd "${PROJECT_ROOT}"

echo "----> Loading dependencies"
go mod download

for target in "${TARGETS[@]}"; do
  os="$(echo "${target}" | cut -d '/' -f1)"
  arch="$(echo "${target}" | cut -d '/' -f2)"
  output="${BINARY_PATH}/${BINARY_NAME}_${os}_${arch}"

  echo "----> Building project for: ${target}"
  GOOS=${os} GOARCH=${arch} CGO_ENABLED=0 go build -o "${output}"
done

echo "----> Prepare config files"
cd "${GITHUB_WORKSPACE}"

echo "----> Compress files"
tar cvfz "${RELEASE_ASSET_NAME}".tar.gz config-files bin

echo "----> Build is complete"

echo "----> Releases info"
github-release info -u local-deploy -r "${BINARY_NAME}"

echo "----> Create release"
github-release release \
  --user local-deploy \
  --repo "${BINARY_NAME}" \
  --tag "${RELEASE_TAG}" \
  --name "${RELEASE_TAG}" \
  --description "${GITHUB_SHA}"

echo "----> Upload files"
github-release upload \
  --user local-deploy \
  --repo "${BINARY_NAME}" \
  --tag "${RELEASE_TAG}" \
  --name "${RELEASE_ASSET_NAME}".tar.gz \
  --file "${RELEASE_ASSET_NAME}".tar.gz
