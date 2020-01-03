data "aws_secretsmanager_secret" "secret_manager" {
  count = length(var.secret_managers)
  name  = var.secret_managers[count.index]
}

data "aws_iam_policy_document" "secrets_manager_get_secret" {
  count = length(var.secret_managers)
  statement {
    sid = "AccessIndicatorsSecrets"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    effect = "Allow"
    resources = [
      data.aws_secretsmanager_secret.secret_manager[count.index].arn
    ]
  }
}

resource "aws_iam_policy" "secrets_manager_get_secret" {
  count  = length(var.secret_managers)
  name   = "SecretManager-${var.app_name}-${var.stage}-${var.lambda_cannonicalname}--${var.secret_managers[count.index]}"
  policy = data.aws_iam_policy_document.secrets_manager_get_secret[count.index].json
}

resource "aws_iam_role_policy_attachment" "secrets_manager_get_secret" {
  count      = length(var.secret_managers)
  depends_on = [aws_iam_policy.secrets_manager_get_secret]

  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.secrets_manager_get_secret[count.index].arn
}
