#!/bin/bash

set -e

PROJECT_ROOT="/go/src/github.com/${GITHUB_REPOSITORY}"
ARTIFACTS_PATH="${GITHUB_WORKSPACE}/.artifacts"
BINARY_NAME=$(basename "${GITHUB_REPOSITORY}")
RELEASE_TAG=$(basename "${GITHUB_REF}")
RELEASE_ASSET_NAME=${BINARY_NAME}-${RELEASE_TAG}
TARGETS=("darwin/amd64" "linux/amd64")

echo "----> Setting up repository"
mkdir -p "${ARTIFACTS_PATH}"
mkdir -p "${PROJECT_ROOT}"
cp -a "${GITHUB_WORKSPACE}"/* "${PROJECT_ROOT}"/
cd "${PROJECT_ROOT}"

echo "----> Loading dependencies"
go mod download

for target in "${TARGETS[@]}"; do
  os="$(echo "${target}" | cut -d '/' -f1)"
  arch="$(echo "${target}" | cut -d '/' -f2)"
  output="${ARTIFACTS_PATH}/${BINARY_NAME}_${os}_${arch}"

  echo "----> Building project for: ${target}"
  GOOS=${os} GOARCH=${arch} CGO_ENABLED=0 go build -o "${output}"
done

echo "----> Prepare config files"
cd "${GITHUB_WORKSPACE}"
cp -r config-files "${ARTIFACTS_PATH}"

echo "----> Compress files"
tar cvfz "${RELEASE_ASSET_NAME}".tar.gz .artifacts/*

echo "----> Build is complete"

echo "----> Create release"
github-release release \
  --user "${GITHUB_ACTOR}" \
  --repo "${BINARY_NAME}" \
  --tag "${RELEASE_TAG}" \
  --name "${RELEASE_TAG}" \
  --description "${GITHUB_SHA}"

echo "----> Upload files"
github-release upload \
  --user "${GITHUB_ACTOR}" \
  --repo "${BINARY_NAME}" \
  --tag "${RELEASE_TAG}" \
  --name "${RELEASE_ASSET_NAME}".tar.gz \
  --file "${RELEASE_ASSET_NAME}".tar.gz
