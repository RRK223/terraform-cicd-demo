#!/bin/bash
# Full path: /home/user/terraform-cicd-demo/update-secrets.sh

# Configuration - CHANGE THESE!
REPO="rrk223/terraform-cicd-demo"  # e.g., "john/terraform-cicd-demo"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=================================================="
echo "AWS Academy Learner Lab - GitHub Secrets Updater"
echo "=================================================="
echo ""

# Function to set AWS credentials
set_aws_credentials() {
    echo -e "${YELLOW}Enter your AWS Academy Learner Lab credentials:${NC}"
    echo ""
    echo "Get these from:"
    echo "1. Click 'AWS Details' button in Learner Lab"
    echo "2. Click 'Show' next to 'AWS CLI'"
    echo ""
    
    read -p "AWS Access Key ID: " AWS_ACCESS_KEY_ID
    read -sp "AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
    echo ""
    echo "Paste your AWS Session Token (the long string):"
    read -s AWS_SESSION_TOKEN
    echo ""
    
    export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
    export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
    export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
    export AWS_DEFAULT_REGION="us-east-1"
    
    echo ""
    echo -e "${YELLOW}Verifying credentials...${NC}"
    
    if aws sts get-caller-identity &> /dev/null; then
        IDENTITY=$(aws sts get-caller-identity --query 'Arn' --output text)
        echo -e "${GREEN}✓ AWS credentials verified!${NC}"
        echo "   Identity: $IDENTITY"
        return 0
    else
        echo -e "${RED}✗ AWS credentials verification failed!${NC}"
        return 1
    fi
}

# Main execution
if ! set_aws_credentials; then
    echo -e "${RED}Failed to set valid AWS credentials. Exiting.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}To update GitHub secrets manually:${NC}"
echo ""
echo "1. Go to: https://github.com/$REPO/settings/secrets/actions"
echo ""
echo "2. Add/update these secrets:"
echo ""
echo "   ┌─────────────────────┬─────────────────────────────────────┐"
echo "   │ Secret Name          │ Value                              │"
echo "   ├─────────────────────┼─────────────────────────────────────┤"
echo "   │ AWS_ACCESS_KEY_ID    │ $AWS_ACCESS_KEY_ID │"
echo "   ├─────────────────────┼─────────────────────────────────────┤"
echo "   │ AWS_SECRET_ACCESS_KEY│ $AWS_SECRET_ACCESS_KEY │"
echo "   ├─────────────────────┼─────────────────────────────────────┤"
echo "   │ AWS_SESSION_TOKEN    │ (long string - see below)          │"
echo "   └─────────────────────┴─────────────────────────────────────┘"
echo ""
echo "3. AWS_SESSION_TOKEN value:"
echo "   $AWS_SESSION_TOKEN"
echo ""
echo -e "${GREEN}✅ Credentials ready to copy!${NC}"
