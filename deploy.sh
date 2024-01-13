#!/usr/bin/env sh

set -e

npm run build

cd dist

git add .
git commit -m 'deploy'

git push -f git@github.com:kenetpicado/apache-config-generator.git main:gh-pages

cd -