#!/usr/bin/env sh

set -e
npm run build
cd docs/.vuepress/dist
git init
git add -A
git commit -m 'deploy'
git push git@github.com:wengzhisong-hz/wengzhisong-hz.github.io.git master
cd -
