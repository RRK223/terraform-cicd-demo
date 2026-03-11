#!/bin/bash
# Script to update GitHub secrets with new Learner Lab credentials

# Configuration - CHANGE THESE!
REPO="YOUR_USERNAME/YOUR_REPO_NAME"  # e.g., "john/terraform-cicd-demo"
GITHUB_USER="YOUR_GITHUB_USERNAME"
GITHUB_TOKEN="YOUR_PERSONAL_ACCESS_TOKEN"  # Create at: github.com/settings/tokens

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=================================================="
echo "AWS Academy Learner Lab - GitHub Secrets Updater"
echo "=================================================="
echo ""

# Check if GitHub CLI is installed
GH_INSTALLED=false
if command -v gh &> /dev/null; then
    GH_INSTALLED=true
    echo -e "${GREEN}✓ GitHub CLI is installed${NC}"
    
    # Check if authenticated
    if gh auth status &> /dev/null; then
        echo -e "${GREEN}✓ GitHub CLI is authenticated${NC}"
    else
        echo -e "${YELLOW}⚠ GitHub CLI not authenticated. Run 'gh auth login' first.${NC}"
        GH_INSTALLED=false
    fi
else
    echo -e "${YELLOW}⚠ GitHub CLI not installed${NC}"
    echo "  Either install it or use manual method"
fi

echo ""
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
echo -e "${YELLOW}Verifying credentials with AWS...${NC}"
if AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
   AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
   AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
   aws sts get-caller-identity --region us-east-1 &> /dev/null; then
    
    IDENTITY=$(AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
               AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
               AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
               aws sts get-caller-identity --region us-east-1 --query 'Arn' --output text)
    
    echo -e "${GREEN}✓ AWS credentials verified!${NC}"
    echo "   Identity: $IDENTITY"
else
    echo -e "${RED}✗ AWS credentials verification failed!${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Updating GitHub secrets...${NC}"

if [ "$GH_INSTALLED" = true ]; then
    # Method 1: Using GitHub CLI
    echo "Using GitHub CLI method..."
    
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
else
    # Method 2: Manual instructions
    echo -e "${YELLOW}GitHub CLI not available. Please update manually:${NC}"
    echo ""
    echo "1. Go to: https://github.com/$REPO/settings/secrets/actions"
    echo ""
    echo "2. Update the following secrets with these values:"
    echo ""
    echo "   ┌─────────────────────┬─────────────────────────────────────┐"
    echo "   │ Secret Name          │ Value to Copy                      │"
    echo "   ├─────────────────────┼─────────────────────────────────────┤"
    echo "   │ AWS_ACCESS_KEY_ID    │ $AWS_ACCESS_KEY_ID │"
    echo "   ├─────────────────────┼─────────────────────────────────────┤"
    echo "   │ AWS_SECRET_ACCESS_KEY│ $AWS_SECRET_ACCESS_KEY │"
    echo "   ├─────────────────────┼─────────────────────────────────────┤"
    echo "   │ AWS_SESSION_TOKEN    │ (long string - copy entire value)  │"
    echo "   └─────────────────────┴─────────────────────────────────────┘"
    echo ""
    echo "3. For AWS_SESSION_TOKEN, copy this entire value:"
    echo "   $AWS_SESSION_TOKEN"
    echo ""
    
    # Save to file as backup
    echo "Saving credentials to temporary file (will be deleted in 30 seconds)..."
    cat > /tmp/aws-creds-$$.txt << EOF
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
EOF
    echo "File saved to: /tmp/aws-creds-$$.txt"
    echo "⚠️  This file will auto-delete in 30 seconds - copy values now!"
    sleep 30
    rm -f /tmp/aws-creds-$$.txt
fi

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}✅ Process complete!${NC}"
echo -e "${GREEN}==================================================${NC}"
echo ""
echo "⚠️  Remember: These credentials expire in 2 hours!"
echo "   Set a reminder to run this script again."
