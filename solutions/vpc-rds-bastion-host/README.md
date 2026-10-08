# Solution 003 — VPC with Private RDS and Bastion Host

A production-style AWS network architecture demonstrating how to deploy a **private Amazon RDS PostgreSQL database** inside a highly available VPC while providing controlled administrative access through a **bastion host**.

The architecture uses two Availability Zones with public and private subnets, Internet Gateway, NAT Gateways, security groups, and Multi-AZ RDS.

> **Architecture:** Administrator → Bastion → Private RDS
> **Private outbound:** Private Application → NAT Gateway → Internet

---

## Architecture

```text
                              ┌─────────────────┐
                              │    Internet     │
                              └────────┬────────┘
                                       │
                                ┌──────▼──────┐
                                │     IGW     │
                                └──────┬──────┘
                                       │
┌──────────────────────────────────────┼─────────────────────────────────────┐
│                              VPC 10.0.0.0/16                              │
│                                      │                                    │
│        Availability Zone A            │           Availability Zone B      │
│                                      │                                    │
│ ┌──────────── Public ────────────┐   │   ┌────────── Public ───────────┐ │
│ │                                │   │   │                              │ │
│ │  Bastion Host      NAT Gateway │   │   │         NAT Gateway          │ │
│ │       ▲               │        │   │   │                              │ │
│ └───────┼───────────────┼────────┘   │   └──────────────────────────────┘ │
│         │               │            │                                    │
│ ┌───────┼────── Private ┼────────┐   │   ┌────────── Private ──────────┐ │
│ │       │               │        │   │   │                              │ │
│ │ Private App / EC2 ────┘        │   │   │       RDS PostgreSQL          │ │
│ │                                │   │   │       Multi-AZ                │ │
│ └────────────────────────────────┘   │   └──────────────────────────────┘ │
│                                      │                                    │
└──────────────────────────────────────┼────────────────────────────────────┘
                                       │
Administrator ── SSH :22 ──> Bastion ── PostgreSQL :5432 ──> RDS
```

---

## Important Traffic Flows

### 1. Administrative access to RDS

The administrator connects to the bastion host using SSH.

```text
Administrator
      │
      │ TCP 22
      │ YOUR_PUBLIC_IP/32
      ▼
Bastion Host
      │
      │ TCP 5432
      │ Bastion Security Group
      ▼
RDS PostgreSQL
```

The RDS database is **not publicly accessible**.

The bastion is the controlled entry point into the private network.

---

### 2. Private application outbound internet access

Private resources can reach the internet through a NAT Gateway.

```text
Private Application / EC2
          │
          ▼
Private Route Table
          │
          ▼
NAT Gateway
          │
          ▼
Internet Gateway
          │
          ▼
Internet
```

The NAT Gateway provides **outbound connectivity**.

It does not make the private subnet publicly accessible.

---

### 3. Bastion → RDS

The Bastion Security Group is allowed to connect to PostgreSQL on port `5432`.

```text
Bastion SG
     │
     │ TCP 5432
     ▼
RDS SG
```

The RDS security group references the bastion security group rather than allowing an IP range.

This avoids exposing PostgreSQL to the internet.

---

## AWS Services

| Service               | Purpose                                       |
| --------------------- | --------------------------------------------- |
| Amazon VPC            | Network isolation                             |
| Internet Gateway      | Internet connectivity for public subnets      |
| NAT Gateway           | Outbound internet access from private subnets |
| Amazon EC2            | Bastion host                                  |
| Amazon RDS PostgreSQL | Managed relational database                   |
| AWS Security Groups   | Network-level access control                  |
| AWS Secrets Manager   | RDS master credential management              |
| Elastic IP            | Stable public IP for NAT Gateway              |
| Terraform             | Infrastructure as Code                        |

---

## Network Design

### VPC

```text
CIDR: 10.0.0.0/16
```

### Public Subnets

| AZ              | CIDR          | Purpose               |
| --------------- | ------------- | --------------------- |
| `eu-central-1a` | `10.0.1.0/24` | Bastion + NAT Gateway |
| `eu-central-1b` | `10.0.2.0/24` | NAT Gateway           |

### Private Subnets

| AZ              | CIDR           | Purpose           |
| --------------- | -------------- | ----------------- |
| `eu-central-1a` | `10.0.11.0/24` | Private workloads |
| `eu-central-1b` | `10.0.12.0/24` | RDS               |

---

## High Availability

The network is distributed across two Availability Zones.

```text
                 VPC
                  │
        ┌─────────┴─────────┐
        │                   │
       AZ-A                AZ-B
        │                   │
    NAT Gateway          NAT Gateway
        │                   │
 Private Subnet        Private Subnet
        │                   │
        └────── RDS ────────┘
              Multi-AZ
```

Each private subnet has its own route table and NAT Gateway in the corresponding Availability Zone.

This avoids relying on a single NAT Gateway for all private-subnet outbound traffic.

---

## Security Groups

### Bastion Security Group

Inbound:

```text
TCP 22
Source: YOUR_PUBLIC_IP/32
```

Outbound:

```text
All IPv4
```

This means only the administrator's specified public IP can initiate SSH access.

---

### RDS Security Group

Inbound:

```text
TCP 5432
Source: Bastion Security Group
```

Outbound:

```text
All IPv4
```

There is no:

```text
0.0.0.0/0 → TCP 5432
```

rule.

Therefore PostgreSQL is not directly exposed to the internet.

---

## RDS Configuration

The solution provisions PostgreSQL with:

| Setting             | Configuration  |
| ------------------- | -------------- |
| Engine              | PostgreSQL     |
| Default version     | 16             |
| Instance            | `db.t4g.micro` |
| Storage             | 20 GiB         |
| Storage type        | gp3            |
| Encryption          | Enabled        |
| Multi-AZ            | Enabled        |
| Public access       | Disabled       |
| Backup retention    | 7 days         |
| Storage autoscaling | Up to 100 GiB  |
| Database port       | 5432           |

The RDS subnet group spans both private subnets.

---

## Database Credentials

The RDS master password is not stored in `terraform.tfvars`.

Terraform enables:

```hcl
manage_master_user_password = true
```

AWS manages the master password using Secrets Manager.

The Terraform output provides the secret ARN:

```text
rds_master_user_secret_arn
```

This allows the credentials to be retrieved securely instead of hard-coding them into the repository.

---

## Bastion Host

The bastion uses the latest Amazon Linux 2023 AMI obtained through the AWS Systems Manager public parameter:

```text
/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64
```

The bastion:

* resides in a public subnet
* receives a public IP
* allows SSH only from the configured `/32`
* can reach the private RDS instance
* uses an encrypted root volume

---

## Project Structure

```text
003-vpc-private-rds-bastion/
├── README.md
├── architecture.html
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── terraform.tfvars.example
```

Reusable infrastructure modules:

```text
modules/
├── vpc/
├── bastion/
└── rds/
```

The solution itself contains only architecture-specific composition.

---

## Terraform Module Design

### VPC Module

Responsible for:

* VPC
* Internet Gateway
* Public subnets
* Private subnets
* Public route table
* Private route tables
* NAT Gateways
* Elastic IPs

```hcl
module "vpc" {
  source = "../../modules/vpc"
}
```

### Bastion Module

Responsible for:

* Bastion Security Group
* SSH ingress rule
* EC2 instance
* Amazon Linux 2023 AMI lookup

```hcl
module "bastion" {
  source = "../../modules/bastion"
}
```

### RDS Module

Responsible for:

* RDS Security Group
* PostgreSQL ingress rule
* DB subnet group
* RDS PostgreSQL instance
* Encryption
* Multi-AZ configuration
* Managed master password

```hcl
module "rds" {
  source = "../../modules/rds"
}
```

---

## Prerequisites

Install:

* Terraform >= 1.6
* AWS CLI
* An AWS account
* AWS credentials
* An existing EC2 key pair

Verify AWS credentials:

```bash
aws sts get-caller-identity
```

---

## Deployment

Navigate to the solution:

```bash
cd solutions/003-vpc-private-rds-bastion
```

Initialize Terraform:

```bash
terraform init
```

Create the variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update:

```hcl
admin_ip_cidr = "YOUR_PUBLIC_IP/32"

bastion_key_name = "your-existing-key-pair"
```

For example:

```hcl
admin_ip_cidr = "198.51.100.25/32"
```

> `198.51.100.25` is an example/documentation address. Replace it with your actual public IPv4 address.

Review:

```bash
terraform plan
```

Deploy:

```bash
terraform apply
```

---

## Connecting to the Bastion

After deployment, Terraform outputs:

```text
bastion_public_ip
```

Connect using:

```bash
ssh -i my-bastion-key.pem ec2-user@<BASTION_PUBLIC_IP>
```

---

## Connecting to PostgreSQL

From the bastion:

```bash
psql \
  -h <RDS_ENDPOINT> \
  -p 5432 \
  -U dbadmin \
  -d appdb
```

The RDS endpoint is private and should not be directly accessible from the public internet.

---

## SSH Tunneling

An alternative is to connect from your local machine through the bastion using an SSH tunnel.

```bash
ssh -i my-bastion-key.pem \
  -L 5432:<RDS_ENDPOINT>:5432 \
  ec2-user@<BASTION_PUBLIC_IP>
```

Then connect locally:

```bash
psql \
  -h localhost \
  -p 5432 \
  -U dbadmin \
  -d appdb
```

Traffic flows through the SSH tunnel:

```text
Local Machine
     │
     │ SSH Tunnel
     ▼
Bastion
     │
     │ TCP 5432
     ▼
Private RDS
```

---

## Terraform Outputs

The solution exposes:

```text
vpc_id
public_subnet_ids
private_subnet_ids
nat_gateway_ids
bastion_instance_id
bastion_public_ip
rds_endpoint
rds_port
rds_master_user_secret_arn
```

---

## Important Security Considerations

### Never expose PostgreSQL publicly

Do not change:

```hcl
publicly_accessible = false
```

to:

```hcl
publicly_accessible = true
```

unless there is a deliberate architectural requirement.

---

### Restrict SSH

Always use a specific administrator IP:

```hcl
admin_ip_cidr = "YOUR_IP/32"
```

Avoid:

```hcl
admin_ip_cidr = "0.0.0.0/0"
```

Opening SSH globally significantly increases the attack surface.

---

### RDS access should use Security Group references

The preferred relationship is:

```text
Bastion SG
    │
    │ TCP 5432
    ▼
RDS SG
```

rather than allowing a broad CIDR range.

---

## Cost Considerations

This architecture intentionally uses managed and highly available networking components, but it is more expensive than a minimal VPC.

The main cost components include:

* NAT Gateways
* Elastic IPs where applicable
* EC2 bastion
* RDS instance
* RDS storage
* RDS backups
* Data transfer

Two NAT Gateways are used because the architecture is designed for Availability Zone resilience.

For a learning/demo environment, remember to destroy the resources when finished:

```bash
terraform destroy
```

---

## Production Considerations

This solution is designed as a portfolio-quality reference architecture while remaining easy to deploy and destroy.

For a production environment, consider:

* `deletion_protection = true`
* final RDS snapshots
* longer backup retention
* AWS Systems Manager Session Manager instead of SSH bastion
* VPC endpoints
* centralized logging
* CloudTrail
* AWS Config
* GuardDuty
* Secrets Manager rotation
* stricter outbound Security Group rules
* AWS Network Firewall where required
* infrastructure state stored in an encrypted remote backend
* separate AWS accounts for environments

---

## Key AWS Concepts Demonstrated

* VPC design
* Public and private subnets
* Availability Zones
* Internet Gateway
* NAT Gateway
* Route tables
* Elastic IP
* Security Groups
* Security Group references
* Bastion host pattern
* Amazon RDS PostgreSQL
* RDS private subnet groups
* RDS Multi-AZ
* RDS encryption
* Secrets Manager
* Terraform modules
* Infrastructure as Code
* Network isolation
* Controlled administrative access

---

## Learning Outcome

This solution demonstrates a fundamental AWS three-tier-style network foundation:

```text
             INTERNET
                 │
                IGW
                 │
        ┌────────┴────────┐
        │                 │
   PUBLIC SUBNETS    PUBLIC SUBNETS
        │                 │
    Bastion            NAT GW
        │                 │
        │            PRIVATE SUBNETS
        │                 │
        └───────┐         │
                ▼         ▼
             RDS       Private Apps
```

The key architectural principle is:

> **Public resources handle controlled internet-facing access, while databases remain private and are accessed through explicitly authorized security-group relationships.**

The NAT Gateway provides outbound internet access for private workloads; **RDS itself does not use the NAT Gateway**.
