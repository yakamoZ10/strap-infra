<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.74.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.74.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.tf_lock_table](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.tf_state](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.tf_state](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.tf_state](https://registry.terraform.io/providers/hashicorp/aws/5.74.0/docs/resources/s3_bucket_ownership_controls) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_access_key"></a> [aws\_access\_key](#input\_aws\_access\_key) | n/a | `string` | n/a | yes |
| <a name="input_aws_secret_key"></a> [aws\_secret\_key](#input\_aws\_secret\_key) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_rn"></a> [bucket\_rn](#output\_bucket\_rn) | n/a |
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | n/a |
<!-- END_TF_DOCS -->