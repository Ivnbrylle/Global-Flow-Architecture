# Global Flow Architecture

Multi-region serverless API infrastructure on AWS, provisioned with Terraform.

This project deploys:

- API Gateway HTTP API in two regions (`us-east-1` and `us-west-2`)
- Regional Lambda functions (Python 3.12)
- DynamoDB Global Table (`GlobalUserTable`) with cross-region replication

## Architecture Diagram

![Multi-Region Serverless API Architecture](assets/Project-Global-Flow-Diagram.jpg)

Reference document: [assets/Project-Global-Flow-Documentation.pdf](assets/Project-Global-Flow-Documentation.pdf)

## What This Deploys

1. Primary stack in `us-east-1`
2. Secondary stack in `us-west-2`
3. Shared DynamoDB Global Table replicated between both regions
4. `/status` endpoint in each region returning a health payload

## Repository Structure

```text
.
├── database.tf                 # DynamoDB Global Table + replica
├── main.tf                     # Root module calls for primary/secondary API stacks
├── outputs.tf                  # Regional API endpoint outputs
├── providers.tf                # AWS providers for east + west
├── variables.tf                # Root input variables
├── src/
│   └── index.py                # Lambda handler
├── modules/
│   └── serverless_api/
│       ├── main.tf             # API Gateway, Lambda, IAM, zip packaging
│       ├── outputs.tf          # Module API outputs
│       ├── providers.tf        # Module provider requirements
│       └── variables.tf        # Module inputs
└── assets/
    ├── Project-Global-Flow-Diagram.jpg
    └── Project-Global-Flow-Documentation.pdf
```

## Prerequisites

- Terraform `>= 1.5`
- AWS account with permissions for:
  - API Gateway v2
  - Lambda
  - IAM
  - DynamoDB
- AWS credentials configured locally (environment variables, profile, or SSO)

## Quick Start

1. Initialize Terraform

```bash
terraform init
```

2. Review execution plan

```bash
terraform plan
```

3. Apply infrastructure

```bash
terraform apply
```

## Validate Deployment

After apply, Terraform prints two outputs:

- `primary_region_url`
- `secondary_region_url`

Test both endpoints:

```bash
curl <primary_region_url>
curl <secondary_region_url>
```

Expected response body contains:

- `message`: API greeting
- `active_region`: runtime region value
- `status`: `Healthy`

## Input Variables

| Name           | Description                           | Default       |
| -------------- | ------------------------------------- | ------------- |
| `project_name` | Project naming variable at root level | `global-flow` |

## Terraform Outputs

| Output                 | Description                             |
| ---------------------- | --------------------------------------- |
| `primary_region_url`   | `/status` endpoint from `us-east-1` API |
| `secondary_region_url` | `/status` endpoint from `us-west-2` API |

## Operational Notes

- Lambda package zip is generated automatically at module path during Terraform runs.
- DynamoDB table name is `GlobalUserTable` and is replicated to `us-west-2`.
- The current Lambda handler is a health response endpoint and does not yet perform DynamoDB reads/writes.

## Security and Git Hygiene

The project `.gitignore` excludes local state, provider cache, environment files, and generated artifacts.

Commit:

- Terraform source (`*.tf`)
- Lock file (`.terraform.lock.hcl`)
- Documentation and source code

Do not commit:

- State files (`*.tfstate`, `*.tfstate.*`)
- Terraform working directory (`.terraform/`)
- Sensitive variable files (`*.tfvars`, `*.auto.tfvars`)
- Local Terraform credential files (`.terraformrc`, `terraform.rc`)

## Cleanup

To destroy all provisioned infrastructure:

```bash
terraform destroy
```
