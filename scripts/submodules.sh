#!/bin/sh
set -e

echo "Checking and pushing submodule changes..."

for sub in dwm st slstatus; do
  if [ -d "$sub/.git" ]; then
    echo "Processing $sub..."
    cd $sub
    if [ -n "$(git status --porcelain)" ]; then
      git add .
      git commit -m "Update from .dotfiles script"
      git push
      echo "$sub: changes committed and pushed."
    else
      echo "$sub: no changes to commit."
    fi
    cd ..
  else
    echo "$sub: not a git submodule or missing .git directory."
  fi
done

echo "Updating submodule references in main repo..."
if [ -n "$(git status --porcelain dwm st slstatus)" ]; then
  git add dwm st slstatus
  git commit -m "Update submodule references"
  git push
  echo "Main repo: submodule references updated and pushed."
else
  echo "Main repo: no submodule reference changes."
fi

echo "Done."