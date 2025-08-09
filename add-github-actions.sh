#!/bin/bash
# add-github-actions.sh - Script to add GitHub Actions workflow
# Run this when you have a Personal Access Token with 'workflow' scope

echo "🔧 Adding GitHub Actions workflow..."

# Check if .github/workflows directory exists
if [ ! -d ".github/workflows" ]; then
    echo "Creating .github/workflows directory..."
    mkdir -p .github/workflows
fi

# Check if ci.yml already exists
if [ -f ".github/workflows/ci.yml" ]; then
    echo "⚠️  GitHub Actions workflow already exists"
    echo "Current workflow file:"
    ls -la .github/workflows/ci.yml
    exit 0
fi

# Copy the workflow from our local version
if [ -f ".github/workflows/ci.yml" ]; then
    echo "✅ GitHub Actions workflow already present locally"
else
    echo "❌ GitHub Actions workflow file not found locally"
    echo "Please ensure .github/workflows/ci.yml exists"
    exit 1
fi

# Add to git
echo "Adding GitHub Actions workflow to git..."
git add .github/workflows/ci.yml

# Commit
echo "Committing GitHub Actions workflow..."
git commit -m "Add GitHub Actions workflow for CI/CD

- Matrix testing across Python versions (3.8, 3.9, 3.10, 3.11)
- Cross-platform testing (Linux, macOS)
- Code linting and style checks (flake8, black, isort, shellcheck)
- Package building validation
- Daily scheduled runs at 2 AM UTC
- PHP 8.1 compatibility testing

Requires Personal Access Token with 'workflow' scope to push."

# Push
echo "Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo "✅ GitHub Actions workflow successfully added!"
    echo "🔗 Check your repository at: https://github.com/$(git remote get-url origin | sed 's/.*github.com[\/:]//g' | sed 's/.git$//g')/actions"
else
    echo "❌ Failed to push GitHub Actions workflow"
    echo "💡 Make sure your Personal Access Token has 'workflow' scope"
fi
