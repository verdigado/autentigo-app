#!/usr/bin/env bash

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

PUBSPEC_VERSION=$(sed -nr 's/^version: (.*)/\1/p' pubspec.yaml)
echo "Current pubspec.yml version: ${PUBSPEC_VERSION}"

BUILD_NAME=$(echo ${PUBSPEC_VERSION} | cut -d+ -f1)
BUILD_NUMBER=$(echo ${PUBSPEC_VERSION} | cut -d+ -f2)
DATE=$(echo ${BUILD_NAME} | cut -d. -f1-2)
COUNTER=$(echo ${BUILD_NAME} | cut -d. -f3)

NEW_DATE=$(date '+%Y.%m')
NEW_COUNTER=0
if [ ${DATE} == ${NEW_DATE} ]; then
  NEW_COUNTER=$(( COUNTER + 1 ))
fi

NEW_BUILD_NAME="${NEW_DATE}.${NEW_COUNTER}"
NEW_BUILD_NUMBER=$(( BUILD_NUMBER + 1 ))
NEW_PUBSPEC_VERSION="${NEW_BUILD_NAME}+${NEW_BUILD_NUMBER}"

echo "Update pubspec.yml version to: ${NEW_PUBSPEC_VERSION}"
sed -i "s/^version: .*/version: ${NEW_PUBSPEC_VERSION}/" pubspec.yaml

if [ ! -z ${CIRCLECI+x} ]; then
  echo "export NEW_PUBSPEC_VERSION=${NEW_PUBSPEC_VERSION}" >> "${BASH_ENV}"
fi
