#!/bin/bash

set -e

VERSION="${TRAVIS_TAG:-0.0.0}"

# Set up Github
if [ -n "$GITHUB_TOKEN" ]; then
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
  git remote add origin-repo "https://${GITHUB_TOKEN}@github.com/SumoLogic/influxdata-helm-charts.git" > /dev/null 2>&1
  git fetch --unshallow origin-repo
  git checkout "${TRAVIS_TAG}"
fi

function push_helm_chart() {
  local project="$1"
  local version="$2"

  echo "Pushing new Helm Chart release $version"
  set -x
  git checkout -- .
  sudo helm package "charts/${project}" --dependency-update --version="${version}" --app-version="${version}"
  git fetch origin-repo
  git checkout gh-pages
  sudo helm repo index ./ --url "https://sumologic.github.io/influxdata-helm-charts/"
  git add -A
  git commit -m "Push new Helm Chart release $version"
  git push --quiet origin-repo gh-pages
  set +x
}

if [[ $VERSION == telegraf-operator/v* ]]; then
  VERSION="${VERSION#telegraf-operator/v}"

  push_helm_chart telegraf-operator "${VERSION}"
fi
