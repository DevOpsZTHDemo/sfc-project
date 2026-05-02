# IAM Groups (RBAC)

resource "aws_iam_group" "admin_group" {
  name = "AdminGroup"
}

resource "aws_iam_group" "dev_group" {
  name = "DevGroup"
}

resource "aws_iam_group" "audit_group" {
  name = "AuditGroup"
}

# IAM Users

resource "aws_iam_user" "admin_user" {
  name = "Rahul"
}

resource "aws_iam_user" "dev_user" {
  name = "Abhishek"

  tags = {
    Department = "Dev"  #this will be used for ABAC
  }
}

resource "aws_iam_user" "audit_user" {
    name = "Satyarth" 

    tags = {
      Department = "Audit"  #this will be used for ABAC
    }
}

#Group Memberships (who belongs in which group)

resource "aws_iam_user_group_membership" "admin_membership" {
  user = aws_iam_user.admin_user.name
  groups = [aws_iam_group.admin_group.name]
}

resource "aws_iam_user_group_membership" "dev_membership" {
  user = aws_iam_user.dev_user.name
  groups = [aws_iam_group.dev_group.name]
}

resource "aws_iam_user_group_membership" "audit_membership" {
  user = aws_iam_user.audit_user.name
  groups = [aws_iam_group.audit_group.name]
}

#RBAC

#Admin - Full Access to all services

resource "aws_iam_group_policy_attachment" "admin_attach" {
  group      = aws_iam_group.admin_group.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#Dev - Custom Policy

resource "aws_iam_policy" "dev_policy" {
  name        = "DeveloperPolicy"
  description = "Custom policy for Dev group"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["ec2:*", "s3:*"]
        Resource = "*"
      }
    ]
    })
}

resource "aws_iam_group_policy_attachment" "dev_attach" {
  group      = aws_iam_group.dev_group.name
  policy_arn = aws_iam_policy.dev_policy.arn
}

#Audit - Read-Only Access

resource "aws_iam_group_policy_attachment" "audit_attach" {
  group      = aws_iam_group.audit_group.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

#ABAC - Attribute-Based Access Control

resource "aws_iam_policy" "abac_policy" {
    name        = "ABACPolicy"
    description = "Policy for ABAC based on user tags"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Action = ["s3:*"]
            Resource = "*"
            Condition = {
            StringEquals = {
                "aws:ResourceTag/Department" = "$${aws:PrincipalTag/Department}"
}
            }
        }
        ]
    })
}   

resource "aws_iam_group_policy_attachment" "abac_attach" {
    group      = aws_iam_group.dev_group.name
    policy_arn = aws_iam_policy.abac_policy.arn
}

# Least Privilege Principle - Example for Dev Group

resource "aws_iam_policy" "least_privilege_policy" {
    name        = "LeastPrivilegePolicy"
    description = "Policy following least privilege principle for Dev group"
    
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect = "Allow"
            Action = ["s3:GetObject"]
            Resource = "arn:aws:s3:::${var.bucket_name}/*"
  }
        ]
    })
}

resource "aws_iam_group_policy_attachment" "least_privilege_attach" {
    group      = aws_iam_group.dev_group.name
    policy_arn = aws_iam_policy.least_privilege_policy.arn
}