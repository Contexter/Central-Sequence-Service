#!/bin/bash

# This script removes all .DS_Store files from the repository and prevents future commits.

echo "Searching for .DS_Store files in the repository..."

# Find and remove all .DS_Store files
find . -name '.DS_Store' -type f -print -delete

echo ".DS_Store files removed from the repository."

# Add the removed files to git for deletion
git ls-files --deleted -z | xargs -0 git rm --cached

# Prevent .DS_Store files from being committed in the future
if ! grep -qxF '.DS_Store' .gitignore; then
  echo ".DS_Store" >> .gitignore
  echo "Added .DS_Store to .gitignore to prevent future commits."
else
  echo ".DS_Store is already in .gitignore."
fi

# Commit the changes
echo "Committing changes to remove .DS_Store files..."
git add .gitignore
git commit -m "chore: remove .DS_Store files and add to .gitignore"

echo "Cleanup complete! All .DS_Store files have been removed and ignored."

