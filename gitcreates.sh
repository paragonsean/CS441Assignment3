#!/bin/bash

# Get the current folder name
REPO_NAME=$(basename "$PWD")
BRANCH_NAME="main"

# Get the authenticated GitHub username
GITHUB_USER=$(gh auth status --show-token | awk 'NR==1 {print $3}')

# Check if the repository already exists on GitHub
if gh repo view "$REPO_NAME" &>/dev/null; then
    echo "✅ GitHub repository '$REPO_NAME' already exists."
else
    echo "🚀 Creating GitHub repository: $REPO_NAME..."
    gh repo create "$REPO_NAME" --public --source=. --push
    echo "✅ Repository '$REPO_NAME' created and linked!"
fi

# Check if .git directory exists
if [ ! -d ".git" ]; then
    echo "Initializing Git repository..."
    git init
    git branch -M "$BRANCH_NAME"
    git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
else
    echo "Git repository already initialized."
fi

# Add all files (excluding nested repositories)
echo "Adding files..."
git add .

# Remove accidental nested Git repository (if detected)
if [ -d "AddressBooks/.git" ]; then
    echo "⚠️ Detected nested Git repository 'AddressBooks'! Removing from tracking..."
    git rm -r --cached AddressBooks
    echo "✅ Removed 'AddressBooks' from tracking."
fi

# Commit changes
COMMIT_MESSAGE="Initial commit"
echo "Committing changes..."
git commit -m "$COMMIT_MESSAGE"

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin "$BRANCH_NAME"

echo "✅ Repository successfully set up and pushed!"
