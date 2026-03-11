#!/bin/bash
# Full path: /home/user/terraform-cicd-demo/test-credentials.sh

echo "Testing AWS Credentials"
echo "======================="

# Test 1: Check environment variables
echo ""
echo "Test 1: Environment Variables"
echo "-----------------------------"
echo "AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:0:10}..."
echo "AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:0:5}..."
echo "AWS_SESSION_TOKEN: ${AWS_SESSION_TOKEN:0:20}... (length: ${#AWS_SESSION_TOKEN})"

# Test 2: AWS CLI
echo ""
echo "Test 2: AWS CLI Call"
echo "-----------------------------"
if aws sts get-caller-identity &>/dev/null; then
    echo "✅ SUCCESS!"
    aws sts get-caller-identity
else
    echo "❌ FAILED!"
fi

# Test 3: Terraform
echo ""
echo "Test 3: Terraform Init"
echo "-----------------------------"
terraform init

echo ""
echo "Test 4: Terraform Plan"
echo "-----------------------------"
terraform plan
