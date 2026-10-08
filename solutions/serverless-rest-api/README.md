# Solution 002 — Serverless REST API

A fully serverless REST-style API built using **Amazon API Gateway HTTP API, AWS Lambda, and Amazon DynamoDB**, provisioned entirely with Terraform.

The solution demonstrates how to build a scalable CRUD API without managing servers or application infrastructure.

> **Architecture:** Client → API Gateway HTTP API → Lambda → DynamoDB

---

## Architecture

```text
┌──────────────┐
│    Client    │
└──────┬───────┘
       │
       │ HTTPS
       ▼
┌──────────────────────────┐
│ API Gateway HTTP API     │
│                          │
│ GET    /items            │
│ POST   /items            │
│ GET    /items/{id}       │
│ PUT    /items/{id}       │
│ DELETE /items/{id}       │
└────────────┬─────────────┘
             │
             │ AWS Proxy
             ▼
┌──────────────────────────┐
│ AWS Lambda               │
│ Python                   │
│                          │
│ CRUD business logic      │
└────────────┬─────────────┘
             │
             │ IAM
             ▼
┌──────────────────────────┐
│ Amazon DynamoDB          │
│                          │
│ Partition Key: id       │
│ Billing: PAY_PER_REQUEST │
└──────────────────────────┘
```

---

## AWS Services

| Service                     | Purpose                              |
| --------------------------- | ------------------------------------ |
| Amazon API Gateway HTTP API | Public API endpoint and HTTP routing |
| AWS Lambda                  | Serverless application logic         |
| Amazon DynamoDB             | Serverless NoSQL persistence         |
| AWS IAM                     | Least-privilege Lambda permissions   |
| Amazon CloudWatch Logs      | Lambda execution logs                |
| Terraform                   | Infrastructure as Code               |

---

## API Endpoints

| Method   | Endpoint      | Description        |
| -------- | ------------- | ------------------ |
| `GET`    | `/items`      | Retrieve all items |
| `POST`   | `/items`      | Create a new item  |
| `GET`    | `/items/{id}` | Retrieve an item   |
| `PUT`    | `/items/{id}` | Update an item     |
| `DELETE` | `/items/{id}` | Delete an item     |

---

## Example Request

### Create an item

```http
POST /items
Content-Type: application/json
```

```json
{
  "name": "AWS Solutions Architecture",
  "description": "Serverless API example"
}
```

Example response:

```json
{
  "id": "b8e5c3d4-...",
  "name": "AWS Solutions Architecture",
  "description": "Serverless API example",
  "created_at": "2026-10-08T10:30:00+00:00",
  "updated_at": "2026-10-08T10:30:00+00:00"
}
```

---

## Project Structure

```text
002-serverless-rest-api/
├── README.md
├── architecture.png
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
└── lambda/
    └── handler.py
```

Reusable infrastructure is implemented through modules:

```text
modules/
├── api-gateway-http/
├── dynamodb/
└── lambda/
```

The solution folder contains only **solution-specific composition**, while reusable AWS infrastructure is maintained under `modules/`.

---

## Terraform Design

The solution composes three reusable modules:

```hcl
module "dynamodb" {
  source = "../../modules/dynamodb"
}
```

```hcl
module "lambda" {
  source = "../../modules/lambda"
}
```

```hcl
module "api_gateway" {
  source = "../../modules/api-gateway-http"
}
```

Lambda receives only the DynamoDB permissions required by this solution.

```text
Lambda
  │
  │ IAM
  ├── GetItem
  ├── PutItem
  ├── UpdateItem
  ├── DeleteItem
  └── Scan
       │
       ▼
   DynamoDB table
```

---

## DynamoDB Configuration

The table uses:

* Partition key: `id`
* Attribute type: String
* Billing mode: `PAY_PER_REQUEST`

This removes the need to provision read/write capacity for the demonstration.

```text
Table
└── id (String) ← Partition Key
```

---

## Lambda Configuration

Default configuration:

| Setting              | Value                    |
| -------------------- | ------------------------ |
| Runtime              | Python 3.12              |
| Memory               | 256 MB                   |
| Timeout              | 10 seconds               |
| Handler              | `handler.lambda_handler` |
| Environment variable | `TABLE_NAME`             |

Each item receives a UUID4 identifier.

---

## Security

The Lambda execution role follows a least-privilege approach.

Lambda is granted access only to the DynamoDB table used by this application.

No AWS credentials are stored in the source code.

API Gateway invokes Lambda through an AWS proxy integration.

---

## Prerequisites

Install:

* Terraform >= 1.6
* AWS CLI
* An AWS account
* AWS credentials configured locally

Verify:

```bash
terraform version
aws sts get-caller-identity
```

---

## Deployment

Navigate to the solution:

```bash
cd solutions/002-serverless-rest-api
```

Initialize Terraform:

```bash
terraform init
```

Create your variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Review the configuration and then run:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Terraform will output the API endpoint.

Example:

```text
api_endpoint = "https://xxxxxxxxxx.execute-api.eu-central-1.amazonaws.com"
```

---

## Testing

Set the API endpoint:

```bash
API_URL="https://xxxxxxxxxx.execute-api.eu-central-1.amazonaws.com"
```

Create an item:

```bash
curl -X POST "$API_URL/items" \
  -H "Content-Type: application/json" \
  -d '{"name":"AWS","description":"Serverless API"}'
```

List items:

```bash
curl "$API_URL/items"
```

Get an item:

```bash
curl "$API_URL/items/<id>"
```

Update:

```bash
curl -X PUT "$API_URL/items/<id>" \
  -H "Content-Type: application/json" \
  -d '{"name":"AWS Updated","description":"Updated item"}'
```

Delete:

```bash
curl -X DELETE "$API_URL/items/<id>"
```

---

## Cleanup

To remove all resources:

```bash
terraform destroy
```

---

## Key AWS Concepts Demonstrated

* API Gateway HTTP APIs
* AWS Lambda
* DynamoDB
* Serverless architecture
* AWS IAM least privilege
* Lambda environment variables
* API Gateway → Lambda integration
* DynamoDB CRUD operations
* Terraform modules
* Infrastructure as Code
* Pay-per-request DynamoDB capacity
* CloudWatch logging

---

## Learning Outcome

This solution demonstrates the fundamental serverless API pattern:

```text
                    SERVERLESS
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    API Gateway      Lambda       DynamoDB
        │              │              │
     Routing        Compute        Storage
```

There are no EC2 instances, load balancers, or servers to manage.

The architecture scales independently based on demand and uses managed AWS services wherever possible.
