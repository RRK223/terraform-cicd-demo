#!/bin/bash
# Script to update GitHub secrets with new Learner Lab credentials

# Configuration - CHANGE THESE!
REPO="YOUR_USERNAME/YOUR_REPO_NAME"  # e.g., "john/terraform-cicd-demo"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================================="
echo "AWS Academy Learner Lab - GitHub Secrets Updater"
echo "=================================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install it from: https://cli.github.com/"
    echo ""
    echo "After installing, run: gh auth login"
    exit 1
fi

# Check if authenticated with GitHub
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}Please login to GitHub first:${NC}"
    gh auth login
fi

echo -e "${YELLOW}Please enter your current Learner Lab credentials:${NC}"
echo ""
echo "Get these from AWS Academy Learner Lab:"
echo "1. Click 'AWS Details'"
echo "2. Click 'Show' next to 'AWS CLI'"
echo ""

read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -sp "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
echo ""
read -sp "AWS Session Token: " AWS_SESSION_TOKEN
echo ""
echo ""

# Verify credentials work
echo -e "${YELLOW}Verifying credentials...${NC}"
if AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
   AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
   AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
   aws sts get-caller-identity --region us-east-1 &> /dev/null; then
    
    IDENTITY=$(AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
               AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
               AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
               aws sts get-caller-identity --region us-east-1 --query 'Arn' --output text)
    
    echo -e "${GREEN}✓ Credentials verified successfully!${NC}"
    echo "   Identity: $IDENTITY"
else
    echo -e "${RED}✗ Credentials verification failed!${NC}"
    echo "   Please check your credentials and try again."
    exit 1
fi

echo ""
echo -e "${YELLOW}Updating GitHub secrets for repository: $REPO${NC}"

# Update secrets (using echo to avoid newline issues)
echo -n "$AWS_ACCESS_KEY_ID" | gh secret set AWS_ACCESS_KEY_ID --repo "$REPO"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ AWS_ACCESS_KEY_ID updated${NC}"
else
    echo -e "${RED}  ✗ Failed to update AWS_ACCESS_KEY_ID${NC}"
fi

echo -n "$AWS_SECRET_ACCESS_KEY" | gh secret set AWS_SECRET_ACCESS_KEY --repo "$REPO"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ AWS_SECRET_ACCESS_KEY updated${NC}"
else
    echo -e "${RED}  ✗ Failed to update AWS_SECRET_ACCESS_KEY${NC}"
fi

echo -n "$AWS_SESSION_TOKEN" | gh secret set AWS_SESSION_TOKEN --repo "$REPO"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ AWS_SESSION_TOKEN updated${NC}"
else
    echo -e "${RED}  ✗ Failed to update AWS_SESSION_TOKEN${NC}"
fi

# Verify secrets were set
echo ""
echo -e "${YELLOW}Verifying secrets in GitHub...${NC}"
SECRETS_LIST=$(gh secret list --repo "$REPO")

if echo "$SECRETS_LIST" | grep -q "AWS_ACCESS_KEY_ID"; then
    echo -e "${GREEN}✓ AWS_ACCESS_KEY_ID is set${NC}"
else
    echo -e "${RED}✗ AWS_ACCESS_KEY_ID not found${NC}"
fi

if echo "$SECRETS_LIST" | grep -q "AWS_SECRET_ACCESS_KEY"; then
    echo -e "${GREEN}✓ AWS_SECRET_ACCESS_KEY is set${NC}"
else
    echo -e "${RED}✗ AWS_SECRET_ACCESS_KEY not found${NC}"
fi

if echo "$SECRETS_LIST" | grep -q "AWS_SESSION_TOKEN"; then
    echo -e "${GREEN}✓ AWS_SESSION_TOKEN is set${NC}"
else
    echo -e "${RED}✗ AWS_SESSION_TOKEN not found${NC}"
fi

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}✅ All done! Your GitHub Actions will now work.${NC}"
echo -e "${GREEN}==================================================${NC}"
echo ""
echo "⚠️  Remember: These credentials expire in 2 hours!"
echo "   Set a reminder to run this script again."
echo ""
echo "📊 To trigger a deployment:"
echo "   git add ."
echo "   git commit -m 'Update deployment'"
echo "   git push"
echo ""
