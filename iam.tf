################################
# IAM
################################
data "aws_iam_policy" "administrator" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = aws_iam_role.ec2.name
  role = aws_iam_role.ec2.name
}

resource "aws_iam_role" "ec2" {
  name               = "${var.prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2" {
  role       = aws_iam_role.ec2.name
  policy_arn = data.aws_iam_policy.administrator.arn
}
