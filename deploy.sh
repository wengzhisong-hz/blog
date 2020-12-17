#!/usr/bin/env sh

set -e
npm run build
cd docs/.vuepress/dist
git init
git add -A
git commit -m 'deploy'
git push -f git@github.com:wengzhisong-hz/wengzhisong-hz.github.io.git master
git branch -D gh-pages
git checkout -b ghpages
git push -f git@github.com:wengzhisong-hz/wengzhisong-hz.github.io.git gh-pages
git checkout master
cd -
