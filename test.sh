# 1. Clean up old files
rm -rf .terraform .terraform.lock.hcl

# 2. Initialize Terraform
terraform init

# 3. Format and validate
terraform fmt
terraform validate

# 4. Test with your credentials
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_SESSION_TOKEN="your-session-token"
export AWS_DEFAULT_REGION="us-east-1"

# 5. Run a plan
terraform plan

# 6. If plan looks good, commit and push
git add .
git commit -m "Fix duplicate variable declarations"
git push origin main
