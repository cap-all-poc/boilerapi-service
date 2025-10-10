# AWS CodeArtifact Publisher Role Setup (GitHub OIDC + GitHub Actions)
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
                    "token.actions.githubusercontent.com:sub": "repo:<REPO-OWNER>/<REPO-NAME>:*"
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

# Golden AMI Builder Role Setup (GitHub OIDC + GitHub Actions)
This guide sets up:

An IAM policy for building and tagging EBS-backed AMIs using Packer
Publishing the AMI ID to AWS Systems Manager (SSM) Parameter Store
Tagging the SSM parameter
Triggering an Auto Scaling Group (ASG) instance refresh
An IAM role with GitHub OIDC trust
GitHub OIDC provider (if not already created)

1. Create IAM Policy for AMI Building
Save the policy to a file:
```
cat > golden-ami-builder-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "STSPermissions",
      "Effect": "Allow",
      "Action": [
        "sts:GetServiceBearerToken"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PackerEC2Permissions",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:StopInstances",
        "ec2:CreateImage",
        "ec2:RegisterImage",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:DescribeVolumes",
        "ec2:CreateVolume",
        "ec2:AttachVolume",
        "ec2:DeleteVolume",
        "ec2:DetachVolume",
        "ec2:ModifyImageAttribute",
        "ec2:DescribeRegions",
        "ec2:CreateKeyPair",
        "ec2:DeleteKeyPair",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:AttachNetworkInterface",
        "ec2:DetachNetworkInterface",
        "iam:PassRole",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:AuthorizeSecurityGroupEgress",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeSecurityGroups"
      ],
      "Resource": "*"
    },
    {
            "Sid": "CodeArtifactRead",
            "Effect": "Allow",
            "Action": [
                "codeartifact:GetAuthorizationToken",
                "codeartifact:GetRepositoryEndpoint",
                "codeartifact:ReadFromRepository",
                "codeartifact:ListPackageVersions"
            ],
            "Resource": "*"
    },
    {
      "Sid": "SSMPublishAndTagAMI",
      "Effect": "Allow",
      "Action": [
        "ssm:PutParameter",
        "ssm:GetParameter",
        "ssm:DeleteParameter",
        "ssm:AddTagsToResource",
        "ssm:ListTagsForResource",
        "ssm:RemoveTagsFromResource",
        "ssm:GetParameters"
      ],
      "Resource": "arn:aws:ssm:*:*:parameter/YOUR_PARAMETER_NAME"
    },
    {
      "Sid": "ASGInstanceRefresh",
      "Effect": "Allow",
      "Action": [
        "autoscaling:StartInstanceRefresh",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeInstanceRefreshes"
      ],
      "Resource": "*"
    }
  ]
}
EOF
```
Create the policy:
```
aws iam create-policy \
  --policy-name golden-ami-builder-policy \
  --policy-document file://golden-ami-builder-policy.json
```

2. Create IAM Role with GitHub OIDC Trust
Save the trust policy:
```
cat > oidc-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<REPO_OWNER>/<REPO_NAME>:ref:refs/heads/<BRANCH>"
        }
      }
    }
  ]
}
EOF
```
Create the role:
```
aws iam create-role \
  --role-name golden-ami-builder-role \
  --assume-role-policy-document file://oidc-trust-policy.json \
  --description "IAM role for GitHub Actions to build golden AMIs using Packer"
```

4. Attach Policy to Role
```
aws iam attach-role-policy \
  --role-name golden-ami-builder-role \
  --policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/golden-ami-builder-policy
```