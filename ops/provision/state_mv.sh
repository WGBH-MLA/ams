#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# Terraform State Migration: root → module.eks
# ─────────────────────────────────────────────────────────────────────
# Run this ONCE after committing the refactored code and before
# running `terraform plan`.  It moves every resource from its old
# root-level address into the new module.eks address so Terraform
# won't try to destroy & recreate them.
#
# Usage (from repo root):
#   cd ops/provision
#   TF_WORKSPACE=notch8 AWS_PROFILE=gbh bash state_mv.sh
#
# After running, verify with:
#   ./bin/tf notch8 plan   # should show 0 changes (or only cosmetic diffs)
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail

export TF_WORKSPACE="${TF_WORKSPACE:-notch8}"
export AWS_PROFILE="${AWS_PROFILE:-gbh}"

echo "=== Moving EKS resources into module.eks ==="
echo "    Workspace: $TF_WORKSPACE"
echo "    Profile:   $AWS_PROFILE"
echo ""

# ── cluster.tf ──
terraform state mv 'aws_eks_cluster.main[0]'                          'module.eks.aws_eks_cluster.main[0]'
terraform state mv 'aws_kms_key.eks[0]'                               'module.eks.aws_kms_key.eks[0]'
terraform state mv 'aws_kms_alias.eks[0]'                             'module.eks.aws_kms_alias.eks[0]'
terraform state mv 'aws_cloudwatch_log_group.eks[0]'                  'module.eks.aws_cloudwatch_log_group.eks[0]'
terraform state mv 'aws_iam_openid_connect_provider.eks[0]'           'module.eks.aws_iam_openid_connect_provider.eks[0]'

# ── iam.tf ──
terraform state mv 'aws_iam_role.eks_cluster[0]'                      'module.eks.aws_iam_role.eks_cluster[0]'
terraform state mv 'aws_iam_role_policy_attachment.eks_cluster_policy[0]' 'module.eks.aws_iam_role_policy_attachment.eks_cluster_policy[0]'
terraform state mv 'aws_iam_role.eks_node[0]'                         'module.eks.aws_iam_role.eks_node[0]'
terraform state mv 'aws_iam_role_policy_attachment.eks_node_worker_policy[0]' 'module.eks.aws_iam_role_policy_attachment.eks_node_worker_policy[0]'
terraform state mv 'aws_iam_role_policy_attachment.eks_node_ecr_policy[0]'    'module.eks.aws_iam_role_policy_attachment.eks_node_ecr_policy[0]'
terraform state mv 'aws_iam_role_policy_attachment.eks_node_cni_policy[0]'    'module.eks.aws_iam_role_policy_attachment.eks_node_cni_policy[0]'
terraform state mv 'aws_iam_role.ebs_csi_driver[0]'                   'module.eks.aws_iam_role.ebs_csi_driver[0]'
terraform state mv 'aws_iam_role_policy_attachment.ebs_csi_driver[0]'  'module.eks.aws_iam_role_policy_attachment.ebs_csi_driver[0]'
terraform state mv 'aws_iam_role.efs_csi_driver[0]'                   'module.eks.aws_iam_role.efs_csi_driver[0]'
terraform state mv 'aws_iam_role_policy_attachment.efs_csi_driver[0]'  'module.eks.aws_iam_role_policy_attachment.efs_csi_driver[0]'
terraform state mv 'aws_iam_openid_connect_provider.github[0]'        'module.eks.aws_iam_openid_connect_provider.github[0]'
terraform state mv 'aws_iam_role.github_actions_deploy[0]'            'module.eks.aws_iam_role.github_actions_deploy[0]'
terraform state mv 'aws_iam_role_policy.github_actions_eks[0]'        'module.eks.aws_iam_role_policy.github_actions_eks[0]'
terraform state mv 'aws_eks_access_entry.github_actions[0]'           'module.eks.aws_eks_access_entry.github_actions[0]'
terraform state mv 'aws_eks_access_policy_association.github_actions[0]' 'module.eks.aws_eks_access_policy_association.github_actions[0]'
terraform state mv 'aws_iam_role.cert_manager[0]'                     'module.eks.aws_iam_role.cert_manager[0]'
terraform state mv 'aws_iam_role_policy.cert_manager_route53[0]'      'module.eks.aws_iam_role_policy.cert_manager_route53[0]'
terraform state mv 'aws_iam_role_policy.eks_node_s3_policy[0]'        'module.eks.aws_iam_role_policy.eks_node_s3_policy[0]'

# ── addons.tf ──
terraform state mv 'aws_eks_addon.ebs_csi_driver[0]'                  'module.eks.aws_eks_addon.ebs_csi_driver[0]'
terraform state mv 'aws_eks_addon.efs_csi_driver[0]'                  'module.eks.aws_eks_addon.efs_csi_driver[0]'
terraform state mv 'aws_eks_addon.vpc_cni[0]'                         'module.eks.aws_eks_addon.vpc_cni[0]'
terraform state mv 'aws_eks_addon.coredns[0]'                         'module.eks.aws_eks_addon.coredns[0]'
terraform state mv 'aws_eks_addon.kube_proxy[0]'                      'module.eks.aws_eks_addon.kube_proxy[0]'

# ── node_groups.tf ──
terraform state mv 'aws_launch_template.eks_nodes[0]'                 'module.eks.aws_launch_template.eks_nodes[0]'
terraform state mv 'aws_eks_node_group.main[0]'                       'module.eks.aws_eks_node_group.main[0]'

# ── efs.tf  (only if EFS was created, not imported) ──
terraform state mv 'aws_security_group.efs[0]'                        'module.eks.aws_security_group.efs[0]'                 || true
terraform state mv 'aws_vpc_security_group_ingress_rule.efs_nfs[0]'   'module.eks.aws_vpc_security_group_ingress_rule.efs_nfs[0]' || true
terraform state mv 'aws_vpc_security_group_egress_rule.efs_egress[0]' 'module.eks.aws_vpc_security_group_egress_rule.efs_egress[0]' || true
terraform state mv 'aws_efs_file_system.main[0]'                      'module.eks.aws_efs_file_system.main[0]'               || true
terraform state mv 'aws_efs_mount_target.main[0]'                     'module.eks.aws_efs_mount_target.main[0]'              || true
terraform state mv 'aws_efs_mount_target.main[1]'                     'module.eks.aws_efs_mount_target.main[1]'              || true
terraform state mv 'aws_efs_mount_target.main[2]'                     'module.eks.aws_efs_mount_target.main[2]'              || true

# ── ingress.tf ──
terraform state mv 'aws_iam_role.aws_load_balancer_controller[0]'                  'module.eks.aws_iam_role.aws_load_balancer_controller[0]'
terraform state mv 'aws_iam_policy.aws_load_balancer_controller[0]'                'module.eks.aws_iam_policy.aws_load_balancer_controller[0]'
terraform state mv 'aws_iam_role_policy_attachment.aws_load_balancer_controller[0]' 'module.eks.aws_iam_role_policy_attachment.aws_load_balancer_controller[0]'
terraform state mv 'helm_release.aws_load_balancer_controller[0]'                  'module.eks.helm_release.aws_load_balancer_controller[0]'
terraform state mv 'helm_release.nginx_ingress[0]'                                'module.eks.helm_release.nginx_ingress[0]'

# ── dns.tf (for_each — keys depend on what's deployed) ──
terraform state mv 'aws_route53_record.ams["ams2"]'       'module.eks.aws_route53_record.ams["ams2"]'       || true
terraform state mv 'aws_route53_record.ams["ams2-demo"]'  'module.eks.aws_route53_record.ams["ams2-demo"]'  || true
terraform state mv 'aws_route53_record.ams["ams2-rancher"]' 'module.eks.aws_route53_record.ams["ams2-rancher"]' || true

# ── rancher.tf ──
terraform state mv 'helm_release.rancher[0]'              'module.eks.helm_release.rancher[0]'              || true

echo ""
echo "=== State migration complete ==="
echo "Run 'terraform plan' to verify — should show 0 changes."
