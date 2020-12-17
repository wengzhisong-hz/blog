#!/usr/bin/env sh

set -e
# 推送到 master
git add -A
git commit -m 'deploy'
git push -f git@github.com:wengzhisong-hz/wengzhisong-hz.github.io.git master

# 推送到gh-pages
git branch -D gh-pages || git branch gh-pages
git branch gh-pages || git checkout gh-pages
git merge master

npm run build
cd docs/.vuepress/dist
git init
git add -A
git commit -m 'deploy'
git push -f git@github.com:wengzhisong-hz/wengzhisong-hz.github.io.git gh-pages

git checkout master
cd -
