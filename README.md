# Terraform - Infrastructure as Code

## Table of Contents
1. [What is Terraform?](#what-is-terraform)
2. [Why Do We Need Terraform?](#why-do-we-need-terraform)
3. [Providers - How Terraform Connects to Clouds](#providers)
4. [Resources - The Building Blocks](#resources)
5. [Variables - Making Code Flexible](#variables)
6. [Outputs - Getting Information Back](#outputs)
7. [State File - How Terraform Remembers](#state-file)
8. [Data Sources - Using Existing Resources](#data-sources)
9. [Modules - Reusing Code](#modules)
10. [Lifecycle Rules - Controlling Behavior](#lifecycle-rules)
11. [Plan and Apply - The Safe Process](#plan-and-apply)

---

## What is Terraform?

Terraform is a tool that lets you write code to create and manage cloud infrastructure. Instead of clicking buttons in AWS, Azure, or Google Cloud, you write simple text files describing what resources you want.

**Simple Example:**
Instead of manually creating a web server through AWS console (clicking many buttons), write:

```hcl
resource "aws_instance" "my_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

Then run: `terraform apply` → Done!

---

## Why Do We Need Terraform?

### 1. **Speed & Automation**
- Create 100 servers in seconds instead of hours
- No more repetitive clicking in consoles

### 2. **Consistency**
- Everyone creates infrastructure the same way
- Dev, Staging, and Production all identical

### 3. **Version Control**
- Store infrastructure code in Git
- Track who changed what and when
- Easy code review before applying changes

### 4. **Easy Disaster Recovery**
- Recreate entire infrastructure by running code again
- No lost resources or forgotten steps

### 5. **Cost Control**
- See everything you created
- Easy to identify and delete unused resources

### 6. **Multi-Cloud Support**
- Same code works with AWS, Azure, Google Cloud
- No need to learn different tools

### 7. **Documentation**
- Code IS the documentation
- No need for separate "How to setup" guides

---

## Providers - How Terraform Connects to Clouds

A **provider** is a plugin that lets Terraform talk to cloud services (AWS, Azure, Google Cloud, etc).

**Simple Example:**

```hcl
provider "aws" {
  region = "us-east-1"
}
```

This tells Terraform: "I want to use AWS in the US-East-1 region"

**Using Multiple Clouds:**

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
}
```

Now you can create resources in both AWS and Azure!

---

## Resources - The Building Blocks

A **resource** is something you want to create (server, database, storage, etc).

**Simple Example - Create a Web Server:**

```hcl
resource "aws_instance" "my_web_server" {
  ami           = "ami-0c55b159cbfafe1f0"   # Linux OS
  instance_type = "t2.micro"                 # Small size
}
```

**Simple Example - Create Storage:**

```hcl
resource "aws_s3_bucket" "my_storage" {
  bucket = "my-unique-bucket-name"
}
```

**Simple Example - Create Database:**

```hcl
resource "aws_db_instance" "my_database" {
  identifier     = "mydb"
  engine         = "mysql"
  allocated_storage = 20  # 20 GB
}
```

---

## Variables - Making Code Flexible

Variables let you change settings without modifying code. Perfect for reusing configurations.

**Simple Example - Server Size:**

```hcl
# Define variable
variable "server_size" {
  description = "Size of the server"
  default     = "t2.micro"
}

# Use it
resource "aws_instance" "web_server" {
  instance_type = var.server_size
}
```

**Change it without modifying code:**

```bash
terraform apply -var="server_size=t2.large"
```

**Real Example - Create Multiple Servers:**

```hcl
variable "instance_count" {
  description = "How many servers to create"
  default     = 1
}

resource "aws_instance" "servers" {
  count         = var.instance_count
  instance_type = "t2.micro"
}
```

Now create 1, 2, or 10 servers just by changing the variable!

---

## Outputs - Getting Information Back

Outputs show you important information after Terraform creates resources.

**Simple Example - Get Server IP:**

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

output "server_ip" {
  description = "The public IP of the server"
  value       = aws_instance.web_server.public_ip
}
```

**After running terraform apply, you see:**

```
Outputs:
server_ip = "54.123.45.67"
```

Now you can SSH into your server!

---

## State File - How Terraform Remembers 

Terraform keeps a record (state file) of everything it created. It's like Terraform's memory.

### How State File Works:

**First time:**
```bash
terraform apply
# Creates: EC2 server
# Stores: "server123 exists with ID i-12345"
```

**Second time:**
```bash
terraform apply
# Checks state: "Server i-12345 already exists"
# Does nothing (smart!)
```

### Why State File is Important:
- Prevents creating duplicate resources
- Tracks what you created
- Knows what to delete when you run `terraform destroy`

### Where is State Stored:
- **Local:** `terraform.tfstate` file on your computer
- **Remote:** S3 bucket, Terraform Cloud (better for teams)

---

### Common State File Issues (Problems You Must Know)

#### Issue 1: State File Gets Out of Sync
**Problem:** Someone manually deletes a resource in AWS console, but Terraform doesn't know about it.

**Example:**
```
Terraform thinks: "I created server i-12345"
Reality: Someone deleted it from AWS console
Result: Terraform tries to delete a resource that doesn't exist = Error!
```

**Solution:** Terraform has a `refresh` command
```bash
terraform refresh  # Updates state file with real AWS status
terraform plan     # Now shows the actual state
```

#### Issue 2: Multiple People Editing Same Infrastructure (Concurrency Conflict)
**Problem:** Two team members run `terraform apply` at the same time → State file gets corrupted!

**Example Scenario:**
```
Person A:
  - Runs: terraform plan (reads state file)
  - Reads: "1 server exists"
  - Modifies code: Add 1 more server
  - Runs: terraform apply (updates state file)

Person B (at the SAME time):
  - Runs: terraform plan (reads OLD state file)
  - Reads: "1 server exists" (doesn't see Person A's change)
  - Modifies code: Add 1 more server
  - Runs: terraform apply (overwrites Person A's changes)

Result: State file is corrupted! Both didn't see each other's changes!
```

**Visual Timeline:**
```
Time 1:  Person A reads state file (1 server)
Time 2:  Person B reads state file (1 server) 
Time 3:  Person A writes state file (2 servers)
Time 4:  Person B writes state file (2 servers) - OVERWRITES Person A's changes!
Result:  Data loss and inconsistency!
```

#### Issue 3: State File Contains Secrets
**Problem:** State file stores passwords, API keys, database passwords in PLAIN TEXT!

**Example:**
```hcl
# In your code
resource "aws_db_instance" "production_db" {
  master_username = "admin"
  master_password = "SuperSecretPassword123!"  # Plain text!
}

# In state file (terraform.tfstate)
{
  "password": "SuperSecretPassword123!"  # VISIBLE!
}
```

**Danger:** If someone gets your `terraform.tfstate` file, they get all your secrets!

#### Issue 4: Large State Files Cause Slow Performance
**Problem:** As you create more resources, state file grows huge → `terraform plan` becomes very slow

---

### How to Protect State Files (5 Ways)

#### Method 1: Use Remote State Storage (RECOMMENDED FOR TEAMS)
Instead of storing state locally, store it on a secure server.

**Problem it solves:**
- Centralized location (single source of truth)
- Automatic state locking (prevents conflicts)
- Encrypted in transit and at rest
- Team can access same state

**Simple Example - Store in S3:**
```hcl
# Create this file: backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true              # Encrypt the file!
    dynamodb_table = "terraform-locks" # Prevent conflicts!
  }
}
```

**What happens:**
```
Before: terraform.tfstate stored on your computer (UNSAFE)
After:  terraform.tfstate stored on AWS S3 (SAFE)
        All team members use the same state file
        Automatic encryption
        State locking prevents conflicts
```

**Real Team Example:**
```
Person A runs: terraform apply
  → Person A gets lock on state file
  → Person A makes changes
  → Person A releases lock
  
Person B tries to run: terraform apply (at same time)
  → Waits for Person A's lock to be released
  → Gets lock
  → Makes changes
  → Releases lock

Result: No conflicts!
```

#### Method 2: Enable State Locking
Prevent multiple people from editing state at the same time.

**How it works:**
```
Person A:
  terraform apply
  → Locks state file (like a door lock)
  → Makes changes
  → Unlocks state file

Person B (tries at same time):
  terraform apply
  → Tries to lock state file
  → "WAIT! File is locked by Person A"
  → Waits for Person A to finish
  → Then gets the lock
```

**S3 + DynamoDB Example:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"  # For state locking!
    encrypt        = true
  }
}
```

The DynamoDB table acts like a "lock file" - only one person can hold it at a time.

#### Method 3: Encrypt the State File
Hide secrets in the state file using encryption.

**Simple Example - Enable Encryption:**
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true    # Enable encryption!
  }
}
```

**What happens:**
```
Before:  Password visible in state file (DANGEROUS)
  {
    "password": "SuperSecretPassword123!"
  }

After:   Password encrypted in state file (SAFE)
  {
    "password": "AaBbCcDdEeFf123456789..." # Encrypted!
  }
```

#### Method 4: Restrict Access to State File
Only allow certain people to access the state file.

**Example - AWS S3 Permissions:**
```hcl
# Only team members can read/write state file
# Public cannot access

# In S3 bucket policy:
- Team Lead: Can read and write
- Team Members: Can read and write
- Contractors: Cannot access
- Public: Cannot access
```

#### Method 5: Use Terraform Cloud/Enterprise (EASIEST)
Terraform Cloud handles all security automatically!

**Simple Setup:**
```hcl
terraform {
  cloud {
    organization = "my-company"
    
    workspaces {
      name = "production"
    }
  }
}
```

**What you get automatically:**
- ✅ Remote state storage (not on your computer)
- ✅ Automatic encryption
- ✅ State locking included
- ✅ Access control
- ✅ State history (see all changes)
- ✅ Team collaboration

---

### Quick Comparison - Where to Store State File

| Method | Best For | Security | Cost | Team Friendly |
|--------|----------|----------|------|---------------|
| Local File | Learning/Testing | ❌ No | Free | ❌ No |
| S3 + DynamoDB | Production Teams | ✅ High | Low $ | ✅ Yes |
| Terraform Cloud | Growing Teams | ✅ High | $ | ✅ Yes |
| Terraform Enterprise | Large Companies | ✅ Very High | $$$ | ✅ Yes |

---

### State File Best Practices

**DO:**
- ✅ Always use remote state for team projects
- ✅ Enable encryption
- ✅ Enable state locking
- ✅ Restrict access to state file
- ✅ Never commit state file to Git
- ✅ Add `terraform.tfstate*` to `.gitignore`

**DON'T:**
- ❌ Store state file locally for team work
- ❌ Commit state file to Git (never!)
- ❌ Share state file via email
- ❌ Store sensitive data in plain text
- ❌ Ignore state locking errors

---

### Example: Team Setup (RECOMMENDED)

**Folder structure:**
```
my-infrastructure/
  backend.tf
  main.tf
  variables.tf
  .gitignore
  
.gitignore contents:
  terraform.tfstate*
  .terraform/
  *.tfvars
```

**backend.tf (Save state in S3):**
```hcl
terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true              # Encrypt
    dynamodb_table = "terraform-locks" # Prevent conflicts
  }
}
```

**Result for your team:**
- All team members use same state file
- Only one person can edit at a time (auto locked)
- State file is encrypted
- Secrets are protected
- Can see who made what changes

---

## Data Sources - Using Existing Resources

Data sources let you read information about resources that already exist (not created by Terraform).

**Simple Example - Use Existing VPC:**

```hcl
# Your company already has a VPC
data "aws_vpc" "existing_vpc" {
  id = "vpc-12345678"
}

# Use it to create a server
resource "aws_instance" "my_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = data.aws_vpc.existing_vpc.main_route_table_id
}
```

**Simple Example - Get Latest Ubuntu Image:**

```hcl
# Find the latest Ubuntu automatically
data "aws_ami" "ubuntu" {
  most_recent = true
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Use it
resource "aws_instance" "server" {
  ami           = data.aws_ami.ubuntu.id  # Latest Ubuntu
  instance_type = "t2.micro"
}
```

---

## Modules - Reusing Code

Modules are reusable packages of Terraform code. Like blueprints!

**Folder Structure:**

```
my_project/
  modules/
    web_server/
      main.tf
      variables.tf
  main.tf
```

**modules/web_server/main.tf:**

```hcl
resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

**modules/web_server/variables.tf:**

```hcl
variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

**main.tf (Use the module):**

```hcl
module "prod_server" {
  source        = "./modules/web_server"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.large"
}

module "dev_server" {
  source        = "./modules/web_server"
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

**Benefits:**
- Write once, use everywhere
- Easy to maintain
- Promotes best practices

---

## Lifecycle Rules - Controlling Behavior

Lifecycle rules control how resources are created, updated, or destroyed.

**Simple Example - Prevent Accidental Deletion:**

```hcl
resource "aws_db_instance" "production_db" {
  allocated_storage = 20
  engine            = "mysql"
  
  lifecycle {
    prevent_destroy = true  # Cannot delete production database!
  }
}
```

If someone tries `terraform destroy`, it will refuse!

**Simple Example - Zero Downtime Updates:**

```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
  }
}
```

When updating:
1. Creates new server first
2. Then destroys old server
3. No downtime!

---

## Plan and Apply - The Safe Process

Terraform uses a two-step process to safely make changes.

**Step 1: Plan (Preview changes)**

```bash
terraform plan
```

Shows what will happen:
```
# aws_instance.my_server will be created
+ resource "aws_instance" "my_server" {
    + ami           = "ami-0c55b159cbfafe1f0"
    + instance_type = "t2.micro"
  }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Step 2: Apply (Make changes)**

```bash
terraform apply
```

Asks for confirmation:
```
Do you want to perform these actions? (yes/no)
```

After approval:
```
aws_instance.my_server: Creating...
aws_instance.my_server: Creation complete [id=i-1234567890abcdef0]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

**Why this is great:**
- See exactly what will happen
- Review before making changes
- Much safer than clicking buttons!

---

## Quick Reference

**Basic Commands:**

```bash
terraform init        # Initialize (run first time)
terraform plan        # Preview changes
terraform apply       # Make changes
terraform destroy     # Delete all resources
terraform show        # See current state
terraform validate    # Check for errors
```

**That's it! Now you understand Terraform!**
