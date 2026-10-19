from pathlib import Path


module_file = Path(".terraform/modules/eks.eks/main.tf")
content = module_file.read_text(encoding="utf-8")

old = '''data "aws_iam_session_context" "current" {
  count = local.create ? 1 : 0'''
new = '''data "aws_iam_session_context" "current" {
  count = (var.create && var.enable_cluster_creator_admin_permissions) || (var.create && var.create_kms_key && local.enable_cluster_encryption_config) ? 1 : 0'''

if old not in content:
    raise SystemExit("Bloco esperado do aws_iam_session_context não foi encontrado")

module_file.write_text(content.replace(old, new, 1), encoding="utf-8")
print("Adaptação AWS Academy aplicada ao módulo EKS")
