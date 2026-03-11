#!/bin/bash
# Script to update GitHub secrets with new Learner Lab credentials

# Configuration - CHANGE THESE!
REPO="RRK223/terraform-cicd-demo"  # e.g., "john/terraform-cicd-demo"

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

# Function to set AWS credentials
set_aws_credentials() {
    echo ""
    echo -e "${YELLOW}Setting AWS credentials from Learner Lab...${NC}"
    echo ""
    
    # Clear any existing AWS variables
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_SECURITY_TOKEN
    unset AWS_DEFAULT_REGION
    
    # Get credentials from user
    echo "Please enter your credentials from AWS Academy Learner Lab:"
    echo ""
    echo "Get these from:"
    echo "1. Click 'AWS Details' button"
    echo "2. Click 'Show' next to 'AWS CLI'"
    echo ""
    
    read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
    read -sp "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
    echo ""
    echo "Paste your AWS Session Token (the long string):"
    read -s AWS_SESSION_TOKEN
    echo ""
    read -p "AWS Region [us-east-1]: " AWS_REGION
    AWS_REGION=${AWS_REGION:-us-east-1}
    
    # Export with single quotes (but using variables safely)
    export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
    export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
    export AWS_DEFAULT_REGION="$AWS_REGION"
    
    echo ""
    echo -e "${YELLOW}Verifying credentials with AWS...${NC}"
    
    # Test credentials
    if aws sts get-caller-identity &> /dev/null; then
        IDENTITY=$(aws sts get-caller-identity --query 'Arn' --output text)
        echo -e "${GREEN}✓ AWS credentials verified!${NC}"
        echo "   Identity: $IDENTITY"
        return 0
    else
        echo -e "${RED}✗ AWS credentials verification failed!${NC}"
        echo ""
        echo "Common issues:"
        echo "1. Did you copy the ENTIRE session token? (should be very long)"
        echo "2. Are you in the same lab session? (credentials expire every 2 hours)"
        echo "3. Did you use the correct region? (usually us-east-1)"
        echo ""
        read -p "Try again? (y/n): " RETRY
        if [[ "$RETRY" == "y" ]]; then
            set_aws_credentials
        else
            return 1
        fi
    fi
}

# Call the function to set credentials
if ! set_aws_credentials; then
    echo -e "${RED}Failed to set valid AWS credentials. Exiting.${NC}"
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
else
    # Method 2: Manual instructions
    echo -e "${YELLOW}GitHub CLI not available. Please update manually:${NC}"
    echo ""
    echo "1. Go to: https://github.com/$REPO/settings/secrets/actions"
    echo ""
    echo "2. Update the following secrets with these values:"
    echo ""
    echo "   ┌─────────────────────┬─────────────────────────────────────┐"
    echo "   │ Secret Name          │ Value                              │"
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
    
    # Save to temporary file
    echo "Saving credentials to temporary file (will auto-delete)..."
    cat > /tmp/aws-creds-$$.txt << EOF
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
EOF
    echo "File saved to: /tmp/aws-creds-$$.txt"
    echo "⚠️  This file will auto-delete in 60 seconds - copy values now!"
    sleep 60
    rm -f /tmp/aws-creds-$$.txt
fi

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}✅ Process complete!${NC}"
echo -e "${GREEN}==================================================${NC}"
echo ""
echo "⚠️  Remember: These credentials expire in 2 hours!"
echo "   Set a reminder to run this script again."
echo ""
echo "Next steps:"
echo "1. Push your code to trigger GitHub Actions:"
echo "   git add ."
echo "   git commit -m 'Update AWS credentials'"
echo "   git push origin main"
echo ""
echo "2. Monitor your pipeline at:"
echo "   https://github.com/$REPO/actions"
