#!/bin/sh
cake build
mkdir -p deploy
cp -r akihabara *.png index.html style.css deploy/.

git checkout gh-pages
cp deploy/* .
git add akihabara *.png index.html style.css
git commit -am 'auto deploy'
git push origin gh-pages
rm -rf deploy

git checkout master
