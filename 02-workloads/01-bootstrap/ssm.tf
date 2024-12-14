resource "aws_ssm_document" "docker_image_deployment" {
  name          = "docker-image-deployment"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "1.2",
    "description": "Deployment document",
    "parameters": {
      "ECRRepositoryUri": {
         "type": "String",
         "description": "AWS ECR Repository Uri.",
         "default": "{{ ssm:ECRRepositoryUri }}"
      },
      "ECRRepositoryUrl": {
         "type": "String",
         "description": "AWS ECR Repository Url.",
         "default": "{{ ssm:ECRRepositoryUrl }}"
      },
      "ImageTagVersion": {
         "type": "String",
         "description": "Image version to pick from private registry.",
         "default": "{{ ssm:ImageTagVersion }}"
      },
      "ServiceName": {
         "type": "String",
         "description": "Service name that is being deployed.",
         "default": "{{ ssm:ServiceName }}"
      },
      "SecretId": {
         "type": "String",
         "description": "Secret id/name where the secrets/values are stored in AWS secret manager.",
         "default": "{{ ssm:SecretId }}"
      },
      "EnvFilePath": {
         "type": "String",
         "description": "The path of the env file we are going to write to.",
         "default": "{{ ssm:EnvFilePath }}"
      },
      "Region": {
         "type": "String",
         "description": "AWS Region on which the secret is created",
         "default": "{{ ssm:Region }}"
      }
    },
    "runtimeConfig": {
      "aws:runShellScript": {
        "properties": [
          {
            "id": "0.aws:runShellScript",
            "runCommand": [
                "aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin {{ ECRRepositoryUrl }} || ( echo \"Failed to login to ECR repo\"; exit 1; )",
                "docker pull {{ ECRRepositoryUri }}:{{ ImageTagVersion }} || ( echo \"Failed pulling the image\"; exit 1; )",
                "aws secretsmanager get-secret-value --secret-id={{ SecretId }} --region=eu-central-1 --query=SecretString | jq -r '.' | jq -r \"to_entries|map(\\\"\\(.key)=\\(.value|tostring)\\\")|.[]\" > {{ EnvFilePath }}",
                "docker image prune -af || ( echo \"Failed removing unused images\"; exit 1; )",
                "cd $(dirname {{ EnvFilePath }}) && docker-compose up || ( echo \"Failed to start Docker Compose services\"; exit 1 )"

            ]
          }
        ]
      }
    }
  }
DOC

  tags = merge({ Name = "docker-image-deployment" }, local.default_tags)

}

