#!/bin/bash

echo "🔧 Fixing Git Remote Issues"
echo "=========================="

# Step 1: Check current git status
echo ""
echo "📊 Current Git Status:"
git status

# Step 2: Check remotes
echo ""
echo "🌐 Current Remotes:"
git remote -v

# Step 3: Configure git if needed
echo ""
echo "⚙️  Configuring Git..."
git config --global user.name "AWS Learner"
git config --global user.email "learner@academy.aws"
echo "✅ Git configured"

# Step 4: Ask for GitHub repo URL
echo ""
echo "📝 Please enter your GitHub repository URL:"
echo "   (e.g., https://github.com/username/terraform-cicd-demo.git)"
read -p "URL: " REPO_URL

if [ -z "$REPO_URL" ]; then
    echo "❌ No URL provided. Exiting."
    exit 1
fi

# Step 5: Add remote
echo ""
echo "➕ Adding remote..."
git remote add origin $REPO_URL
if [ $? -eq 0 ]; then
    echo "✅ Remote added successfully"
else
    echo "⚠️  Remote may already exist. Trying to update..."
    git remote set-url origin $REPO_URL
    echo "✅ Remote URL updated"
fi

# Step 6: Check branch and rename if needed
echo ""
echo "🌿 Checking branch..."
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

if [ "$CURRENT_BRANCH" = "master" ]; then
    echo "Renaming master to main..."
    git branch -m master main
    echo "✅ Branch renamed to main"
elif [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Creating main branch..."
    git checkout -b main
fi

# Step 7: Add and commit files
echo ""
echo "📦 Adding files to commit..."
git add .
echo "✅ Files staged"

echo ""
echo "💾 Committing files..."
git commit -m "Initial commit: Terraform CI/CD setup"
echo "✅ Files committed"

# Step 8: Push to GitHub
echo ""
echo "🚀 Pushing to GitHub..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "📎 Your repository is now available at:"
    echo "   $REPO_URL"
else
    echo "❌ Push failed. Trying with force push (if needed)..."
    echo ""
    echo "If this fails, you may need to:"
    echo "1. Create the repository on GitHub first"
    echo "2. Use a Personal Access Token instead of password"
    echo "3. Check if repository exists and you have access"
    
    # Alternative: Try force push
    echo ""
    echo "Attempting force push (use with caution)..."
    git push -u origin main --force
fi

# Step 9: Verify
echo ""
echo "🔍 Verifying..."
git remote -v
git branch -a

echo ""
echo "========================================="
echo "✅ Git Remote Fix Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Run ./update-secrets.sh to update AWS credentials"
echo "2. Check GitHub Actions: $REPO_URL/actions"
