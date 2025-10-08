AWS CodeArtifact Publisher Role Setup (GitHub OIDC + GitHub Actions)
This guide sets up:

An IAM policy for publishing Python packages to AWS CodeArtifact
An IAM role with GitHub OIDC trust
GitHub OIDC provider (if not already created)


🔧 Prerequisites

AWS CLI configured
Replace placeholders like <ACCOUNT_ID>, <REPO_NAME>, <BRANCH> with actual values


📁 1. Create IAM Policy for CodeArtifact Publishing
Save the policy to a file:
```
cat > codeartifact-publish-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CodeArtifactPublish",
      "Effect": "Allow",
      "Action": [
        "codeartifact:GetAuthorizationToken",
        "codeartifact:GetRepositoryEndpoint",
        "codeartifact:PublishPackageVersion",
        "codeartifact:PutPackageMetadata",
        "codeartifact:ReadFromRepository"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AllowSTS",
      "Effect": "Allow",
      "Action": "sts:GetCallerIdentity",
      "Resource": "*"
    }
  ]
}
EOF
```
Create the policy
```
aws iam create-policy \
  --policy-name codeartifact-publish-policy \
  --policy-document file://codeartifact-publish-policy.json
  ```

2. Create IAM Role with GitHub OIDC Trust
Save the trust policy:

'''
cat > oidc-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<ACCOUNTID>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:cap-all-poc/immutable-bakery-iac:*"
                }
            }
        }
    ]
}
EOF
```
create the role
```
aws iam create-role \
  --role-name codeartifact-publish-role \
  --assume-role-policy-document file://oidc-trust-policy.json
```
3. Create GitHub OIDC Provider (if not already created)
```
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98c6f0fae7e0f5b5f1a3b2e0e3b3b3e3
```
4. Attach Policy to Role
```
aws iam attach-role-policy \
  --role-name codeartifact-publish-role \
  --policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/codeartifact-publish-policy
```