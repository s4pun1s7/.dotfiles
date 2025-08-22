#!/bin/sh
# Script to commit and push .gitignore changes in all submodules
echo "Updating submodule .gitignore files..."


for sub in dwm st slstatus; do
  if [ -d "$sub/.git" ]; then
    echo "Processing $sub..."
    cd $sub
    git pull --rebase || echo "Could not pull in $sub"
    git add .gitignore
    git commit -m "Standardize .gitignore file" || echo "No changes to commit in $sub"
    git push || echo "Could not push in $sub"
    cd ..
  else
    echo "$sub is not initialized as a submodule or missing .git directory. Skipping."
  fi
done

echo "Done."
