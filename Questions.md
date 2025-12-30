# TERRAFORM INTERVIEW QUESTIONS & ANSWERS (60 Questions Total)

## PART 1: 40 FOUNDATIONAL QUESTIONS

### Section 1: Basics (Q1-10)

**Q1: What is Terraform?**
Terraform is an open-source Infrastructure as Code (IaC) tool by HashiCorp. Write code in .tf files to describe cloud infrastructure (VMs, networks, databases), then Terraform automatically creates/updates/destroys them. Think of it as a blueprint for your cloud that runs the same way every time.

**Q2: What is Infrastructure as Code (IaC)?**
Treat infrastructure like code files instead of manual console clicking. Benefits: version control with Git, repeatability, no human errors, easy sharing with teams, fast disaster recovery.

**Q3: What is HCL?**
HashiCorp Configuration Language - Terraform's simple language for defining infrastructure.

**Q4: Terraform vs Ansible?**
Terraform = Infrastructure provisioning (creates VMs, networks). Ansible = Configuration management (installs software). Use both together: Terraform builds it, Ansible configures it.

**Q5: What is a Provider?**
Plugins that let Terraform talk to clouds (AWS, Azure, GCP). Declare: provider "aws" { region = "us-east-1" }

**Q6: What is a Resource?**
Building blocks Terraform manages (EC2 instances, S3 buckets, VPCs). Example: resource "aws_instance" "web" creates one EC2 server.

**Q7: What is terraform init?**
Initializes your project. Downloads provider plugins, sets up backend for state file. Run first: terraform init

**Q8: What is terraform plan?**
Previews changes without applying. Shows what will be created (+), updated (~), or destroyed (-). Always run before apply!

**Q9: What is terraform apply?**
Applies the plan - actually creates/updates resources. Shows plan, asks for confirmation (yes/no). Updates terraform.tfstate file.

**Q10: What is terraform destroy?**
Deletes all resources Terraform created. Dangerous - use with care. Good for cleaning test environments.

### Section 2: State Management (Q11-20)

**Q11: What is the State File (terraform.tfstate)?**

A JSON file tracking real-world resources. Maps your code to actual cloud resources (e.g., aws_instance.web -> EC2 i-12345). Without it, Terraform doesn't know what exists. Never edit manually!

**Q12: Where should you store the state file?**

Local (testing): terraform.tfstate in folder - INSECURE. Remote (production): S3, Azure Blob, Terraform Cloud - SECURE, encrypted, locked. For teams: Always use remote backend with state locking!

**Q13: What is a Remote Backend?**

Stores state on a server instead of locally. Example: S3 + DynamoDB. Backend "s3" { bucket="my-state" key="prod/terraform.tfstate" region="us-east-1" encrypt=true dynamodb_table="terraform-locks" }. Benefits: Team access, security, state locking prevents conflicts.

**Q14: What is State Locking?**

Prevents multiple people editing simultaneously. When Person A runs terraform apply, state locks. Person B waits. Uses DynamoDB or backend-specific locks.

**Q15: What is Terraform Cloud?**

Hosted SaaS by HashiCorp. Manages state remotely, runs plans in cloud, enables collaboration. Free tier available. Setup: terraform { cloud { organization="my-company" workspaces { name="production" } } }

**Q16: What to add in .gitignore?**

Prevent committing sensitive files: terraform.tfstate*, .terraform/, *.tfvars, crash.log. Never commit state files or secrets!

**Q17: Can you put secrets in Terraform code?**

NO! Hardcoded passwords appear in state file in PLAIN TEXT. Solutions: Use sensitive=true in variable, Terraform Cloud secrets, AWS Secrets Manager, or HashiCorp Vault.

**Q18: Difference: .tf vs .tfvars files?**

.tf = Define infrastructure (resources, variables, outputs, providers). .tfvars = Pass VALUES to variables (dev.tfvars, prod.tfvars).

**Q19: How to pass variables?**

Three ways: Command line: terraform apply -var="instance_type=t2.large". File: terraform apply -var-file="dev.tfvars". Environment: export TF_VAR_instance_type=t2.large

**Q20: What is terraform show?**

Displays state file contents. Shows all managed resources. Useful for debugging: terraform show

### Section 3: Variables & Outputs (Q21-30)

**Q21: What are Variables?**

Inputs making code flexible. Define: variable "instance_type" { description="EC2 type" default="t2.micro" type=string }. Use: instance_type=var.instance_type

**Q22: What are Outputs?**

Results displayed after apply. Example: output "server_ip" { value=aws_instance.web.public_ip }. View: terraform output

**Q23: What are Data Sources?**

Read-only info about existing resources. Example: data "aws_ami" "ubuntu" { most_recent=true filter { name="name" values=["ubuntu-focal-20.04-*"] } }. Use: ami=data.aws_ami.ubuntu.id

**Q24: Difference: Variables vs Locals?**

variable = External input, changeable. locals = Internal constants. Example: locals { project="myapp" }. Use: local.project

**Q25: What is Type in Variables?**

Restricts variable values. Types: string, number, bool, list, map, object. Example: variable "count" { type=number }

**Q26: What is for_each?**

Creates resources from map/set: resource "aws_instance" "web" { for_each=toset(["web1","web2"]) instance_type="t2.micro" }. Access: aws_instance.web["web1"].id

**Q27: What is count?**

Creates resources with counter: resource "aws_instance" "web" { count=3 instance_type="t2.micro" }. Access: aws_instance.web[0].id

**Q28: Difference: count vs for_each?**

count = Simple loops, unstable if order changes. for_each = Better for maps, stable. RECOMMENDED: Use for_each!

**Q29: What is depends_on?**

Explicit dependencies: resource "aws_instance" "app" { depends_on=[aws_db_instance.main] }. App waits for DB.

**Q30: What is splat syntax?**

Get attributes from multiple resources: output "ips" { value=aws_instance.web[*].private_ip }. Returns list of all IPs.

### Section 4: Modules & Organization (Q31-40)

**Q31: What are Modules?**

Reusable code packages. Folder: modules/vpc/main.tf, modules/vpc/variables.tf, modules/vpc/outputs.tf, main.tf (use module).

**Q32: How to use a Module?**

module "prod_vpc" { source="./modules/vpc" cidr_block="10.0.0.0/16" }. Access outputs: module.prod_vpc.vpc_id

**Q33: What is Remote Module Source?**

Use modules from Git or Registry: module "vpc" { source="github.com/user/vpc-module" } or source="terraform-aws-modules/vpc/aws"

**Q34: What are Lifecycle Rules?**

Control resource behavior: lifecycle { create_before_destroy=true prevent_destroy=true ignore_changes=[tags] }

**Q35: What is prevent_destroy?**

Blocks accidental deletion: lifecycle { prevent_destroy=true }. terraform destroy fails. Must remove rule first.

**Q36: What is create_before_destroy?**

Creates new resource BEFORE destroying old (zero downtime): lifecycle { create_before_destroy=true }. Old lives until new ready!

**Q37: What is terraform validate?**

Checks syntax errors: terraform validate. Catches typos before applying. Useful in CI/CD.

**Q38: What is terraform fmt?**

Auto-formats code: terraform fmt. Beautifies all .tf files.

**Q39: What is terraform taint?**

Marks resource for recreation: terraform taint aws_instance.web. Next apply rebuilds it.

**Q40: What is terraform import?**

Imports existing cloud resource: terraform import aws_instance.web i-12345678. Now Terraform manages it!

---

## PART 2: 20 SCENARIO-BASED QUESTIONS

**S1: Team member changed prod DB manually in AWS console. Terraform shows changes. What do you do?**

ANSWER: This is "drift" - manual changes outside Terraform. Options: 1) Accept drift with lifecycle ignore_changes 2) Undo manually, Terraform becomes empty 3) Taint and recreate. BEST: Use Terraform exclusively!

**S2: Create 3 servers: t2.small (dev), t2.medium (staging), t2.large (prod)?**

ANSWER: Use for_each: resource "aws_instance" "web" { for_each={dev="t2.small" staging="t2.medium" prod="t2.large"} instance_type=each.value tags {Name=each.key} }

**S3: Colleague and you run terraform apply simultaneously. State corrupts. How fix?**

ANSWER: Implement remote backend with state locking (S3+DynamoDB or Terraform Cloud). Person A runs apply -> state locks. Person B waits. PREVENT: Always use remote backend for teams!

**S4: Database upgrade (5.7->8.0) will destroy old DB. Prevent data loss?**

ANSWER: 1) Backup manually first 2) Add lifecycle{create_before_destroy=true} 3) Plan carefully with downtime window 4) Use RDS backups. LESSON: Never destroy prod DBs without backups!

**S5: Manage dev, staging, prod with ONE code. How?**

ANSWER: Use workspaces + variable files: terraform workspace new prod, terraform workspace select prod, terraform apply -var-file="prod.tfvars". Each workspace = separate state: dev/terraform.tfstate, prod/terraform.tfstate

**S6: Secret DB password exposed in state file. What do?**

ANSWER: 1) IMMEDIATE: Rotate password in RDS 2) Update code: variable "db_password" {sensitive=true} 3) Secure state: Terraform Cloud or encrypt S3 4) PREVENT: Use AWS Secrets Manager, never hardcode!

**S7: Create 100 servers. Impractical to write 100 resources?**

ANSWER: Use count or for_each: resource "aws_instance" "web" { count=100 instance_type="t2.micro" }. Or with map (better): for_each=var.server_configs

**S8: VPC manually created. How to manage with Terraform?**

ANSWER: Use terraform import: 1) Write resource "aws_vpc" "main" {...} 2) terraform import aws_vpc.main vpc-12345678 3) Refine code to match 4) terraform plan shows no changes. Now Terraform manages it!

**S9: Staging works fine, prod fails. Why?**

ANSWER: Common causes: Different variables (staging=t2.small, prod=t2.large). Different regions. Missing IAM permissions. Different provider configurations. Solution: Use same code with different .tfvars files!

**S10: How to safely delete a resource WITHOUT destroying it?**

ANSWER: Remove from Terraform only: terraform state rm aws_instance.web. Removes from state but keeps resource. Then remove from code. Resource survives!

**S11: Your Terraform code works locally but fails in CI/CD pipeline. Why?**

ANSWER: Common: Missing AWS credentials in CI/CD. Different Terraform versions. Missing backend config. Solution: Set environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY) in CI/CD secrets. Lock Terraform version with required_version.

**S12: Multiple teams managing same infrastructure. Conflicts occur. Prevent?**

ANSWER: Use separate workspaces per team: Team A = dev/terraform.tfstate, Team B = staging/terraform.tfstate. Or separate state files entirely. Use state locking (mandatory!). Implement PR review process for all changes.

**S13: You accidentally delete a resource locally. How to recover?**

ANSWER: 1) If state backup exists, restore it 2) If Terraform Cloud, access history 3) If Git history, revert changes 4) Manually recreate resource, then terraform import it. LESSON: Regular state backups essential!

**S14: Terraform plan takes 5 minutes. Too slow! Optimize?**

ANSWER: Slow causes: Large state files, many API calls, network latency. Solutions: Split infrastructure into modules/workspaces. Use targeted apply: terraform apply -target=aws_instance.web. Enable parallel: -parallelism=10. Cache API calls.

**S15: You need to rename a resource without destroying it?**

ANSWER: Use moved block (Terraform 1.1+): moved { from=aws_instance.old to=aws_instance.new }. Keeps state, renames resource. Or: terraform state mv aws_instance.old aws_instance.new

**S16: Prod deployment fails halfway. State is inconsistent. What now?**

ANSWER: 1) Never rerun apply (risky) 2) Analyze terraform show - see what succeeded 3) terraform plan to see remaining work 4) Fix issues manually if needed 5) Then terraform apply to complete. LESSON: Always backup state before major changes!

**S17: Team wants infrastructure in code, but legacy resources exist. How migrate?**

ANSWER: Gradual migration: 1) Create new resources with Terraform 2) Import legacy resources one-by-one: terraform import 3) Test thoroughly 4) Gradually switch to Terraform-managed resources 5) Decommission old manual resources. SAFE approach!

**S18: Need to temporarily destroy prod for testing, then restore?**

ANSWER: DANGEROUS! Better: Use terraform workspace for test copy. Or terraform state commands to swap states. Or create separate test environment. NEVER destroy prod! Data loss risk!

**S19: Colleague left, no one knows our Terraform code. Documentation?**

ANSWER: SOLUTION: 1) Write README.md explaining folder structure 2) Comment complex resources 3) Document variable meanings in variables.tf 4) Maintain runbooks for common tasks 5) Use git commit messages explaining WHY. Prevention: Knowledge sharing!

**S20: You want zero-downtime deployment. How with Terraform?**

ANSWER: Use lifecycle rules: create_before_destroy=true. Deploy load balancer first. Add new instances while old running. Then terminate old. Use auto-scaling groups for gradual rollout. Blue-green deployments with Terraform modules. RESULT: Zero downtime!
