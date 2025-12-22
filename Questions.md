

---

## Part 1: Foundations (50 Core Questions)

### Section 1: The Basics

1. **What is Terraform?** An open-source Infrastructure as Code (IaC) tool by HashiCorp used to define and provision infrastructure using a high-level configuration language (HCL).
2. **What is "Infrastructure as Code"?** The process of managing and provisioning computing infrastructure through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.
3. **Terraform vs. Ansible?** Terraform is an **orchestration** tool (best for provisioning infrastructure like VPCs, VMs). Ansible is a **configuration management** tool (best for installing software and configuring OS settings).
4. **What is HCL?** HashiCorp Configuration Language. It is the declarative language used in Terraform files (.tf).
5. **What are Providers?** Plugins that allow Terraform to interact with cloud providers, SaaS providers, and other APIs (e.g., AWS, Azure, GCP).
6. **Purpose of `terraform init`?** Initializes a working directory containing configuration files, downloads provider plugins, and sets up the backend.
7. **Purpose of `terraform plan`?** Creates an execution plan, letting you preview what Terraform will do before making any real changes.
8. **Purpose of `terraform apply`?** Executes the actions proposed in a Terraform plan.
9. **Purpose of `terraform destroy`?** Used to terminate all resources managed by your infrastructure project.
10. **Declarative vs. Imperative?** Terraform is **declarative** (you define the "what"). You describe the end state, and Terraform figures out how to get there.

### Section 2: Variables & Data

11. **Input Variables:** Used as parameters to customize configurations.
12. **Output Values:** Used to show information on the CLI after an apply (e.g., Load Balancer URL).
13. **Local Values:** Internal variables used for repetitive logic within a module.
14. **Sensitive Variables:** Variables marked `sensitive = true` to hide their values in logs and CLI output.
15. **.tfvars files:** Files used to set values for variables (e.g., `dev.tfvars`, `prod.tfvars`).
16. **Variable Precedence:** Environment Variables < `terraform.tfvars` < `*.auto.tfvars` < `-var` flag.
17. **Data Sources:** Allow data to be fetched from external sources or existing infrastructure not managed by the current Terraform code.
18. **Can you use variables in the provider block?** Yes, often used for region or credentials.
19. **What is a Map variable?** A collection of key-value pairs (e.g., tags).
20. **What is a List variable?** A sequence of values (e.g., a list of subnet IDs).

### Section 3: State Management

21. **The State File (`terraform.tfstate`):** A JSON file that maps your code to real-world resources.
22. **Why use a Remote Backend?** For collaboration, security, and state locking.
23. **State Locking:** Prevents multiple users from running Terraform at the same time to avoid state corruption.
24. **Lost State File?** You must rewrite the code and use `terraform import` to rebuild the state.
25. **What is "Drift"?** When the real-world infrastructure changes manually and no longer matches the Terraform code.
26. **Targeted Apply?** Using `-target` to apply/destroy only one specific resource.
27. **`terraform refresh`:** Updates the state file with the real-world status of resources.
28. **`terraform state mv`:** Renames a resource in the state without destroying it.
29. **`terraform show`:** Provides human-readable output of the state or plan.
30. **Where is state stored by default?** Locally in the current directory.

### Section 4: Advanced Logic & Modules

31. **`count`:** Creates a fixed number of identical resources.
32. **`for_each`:** Creates resources based on a map or set (more flexible than count).
33. **`depends_on`:** Explicitly defines a dependency between resources.
34. **`lifecycle` block:** Rules for resource behavior (e.g., `prevent_destroy`).
35. **`ignore_changes`:** Ignores manual changes to specific attributes in the cloud.
36. **`create_before_destroy`:** Builds the replacement resource before deleting the old one.
37. **Null Resource:** A resource that does nothing but can run scripts via provisioners.
38. **Provisioners:** Used to run scripts on a local (`local-exec`) or remote (`remote-exec`) machine.
39. **Why avoid Provisioners?** They are not tracked by the state file and can be unreliable.
40. **Conditionals:** Using ternary operators for resource creation (e.g., `count = var.env == "prod" ? 5 : 1`).
41. **What is a Module?** A container for multiple resources used together.
42. **Root Module:** The directory where `terraform apply` is executed.
43. **Terraform Cloud:** A managed service for Terraform state, UI, and VCS integration.
44. **Workspaces:** Manage multiple state files for different environments from the same code.
45. **Multi-cloud Strategy:** Using multiple provider blocks in the same configuration.
46. **`terraform validate`:** Checks syntax and internal consistency.
47. **`terraform fmt`:** Rewrites configuration files to a canonical format.
48. **Dependency Graph:** The visual map Terraform builds to determine the order of operations.
49. **Version Constraints:** Using `required_version` to lock Terraform versions for a team.
50. **Module Versioning:** Using the `version` attribute when calling modules from a registry.

---

## Part 2: Expert Deep Dives (5 Advanced Concepts)

51. **Detailed `count` vs `for_each**`
Experts prefer `for_each` because it uses strings/keys instead of numeric indexes. With `count`, removing an item from the middle of a list causes every subsequent resource to be re-indexed (destroyed and recreated). `for_each` preserves the identity of each resource.
52. **The 3-Way Merge (Plan Logic)**
A `plan` is a reconciliation of three sources: **Code** (Desired State), **State File** (Memory), and **Cloud API** (Actual State). Terraform refreshes the state against the API before calculating the difference (the delta).
53. **Safe Refactoring with `moved` blocks**
In Terraform v1.1+, you can use `moved` blocks in your code to rename resources. This allows you to refactor your code structure (like moving a resource into a module) without Terraform trying to delete and recreate the physical resource.
54. **S3 + DynamoDB Architecture**
A professional AWS backend uses S3 for encrypted storage of the state file and DynamoDB for "State Locking." DynamoDB ensures that only one process can modify the state at a time.
55. **Immutable Infrastructure**
Terraform promotes "Immutable" infrastructure. Instead of patching a running server, you update the code (e.g., change the AMI ID) and Terraform destroys the old server and creates a fresh new one.

---

## Part 3: Scenario-Based Challenges (10 Practical Scenarios)

### Scenario 1: The "Hanging Lock"

* **Scenario:** You receive an error: `Error: Error acquiring the state lock`. No one is running Terraform.
* **Fix:** A previous process likely crashed. Identify the Lock ID from the error and run `terraform force-unlock <LOCK_ID>`.

### Scenario 2: The "Ghost" Resource

* **Scenario:** A resource exists in the cloud but is missing from your state file.
* **Fix:** Use `terraform import <resource_address> <physical_id>` to bring it back into management.

### Scenario 3: The "Password Leak"

* **Scenario:** State file with secrets committed to Public Git.
* **Fix:** Rotate all credentials immediately. Move state to a remote backend. Use `.gitignore` for `.tfstate` files. Purge Git history using BFG Repo-Cleaner.

### Scenario 4: The "Dependency Loop"

* **Scenario:** Resource A depends on B, and B depends on A.
* **Fix:** Break the cycle. Use a third resource (like a security group rule resource) to link them rather than defining them inside the main resource blocks.

### Scenario 5: The "Sensitive" Output

* **Scenario:** You want to output a DB password but hide it from logs.
* **Fix:** Set `sensitive = true` in the output block.

### Scenario 6: Version Mismatch

* **Scenario:** Different developers using different Terraform versions.
* **Fix:** Implement a `required_version` constraint in the `terraform {}` block to enforce a specific version for the whole team.

### Scenario 7: Module Refactor

* **Scenario:** Moving existing code into a module causes Terraform to want to delete/recreate everything.
* **Fix:** Use a `moved {}` block to tell Terraform the new address of the resource.

### Scenario 8: Partial Success (Rate Limiting)

* **Scenario:** 50 out of 100 resources are created, then the API fails.
* **Fix:** Terraform saves the state for the successful 50. Fix the error and run `apply` again; it will pick up where it left off.

### Scenario 9: Multi-Region Peering

* **Scenario:** You need to connect VPCs in `us-east-1` and `us-west-2`.
* **Fix:** Use Provider Aliases. Create two providers for AWS with different aliases and specify which to use in the `provider` attribute of each resource.

### Scenario 10: Manual Portal Change (Drift)

* **Scenario:** An admin manually changed a VM size in the portal to handle traffic.
* **Fix:** Run `terraform plan`. To keep the change, update your code to match. To revert the change, run `apply` to force the cloud back to the code's configuration.

---



## The Scenario 11:** 50 VMs were renamed manually in the portal. Terraform wants to destroy and recreate them because "name" is a force-new attribute.
**The Solution:** Update the code with the new names, run `terraform state rm` for the old addresses, and then `terraform import` for the new IDs. This reconciles the state without any downtime.

---

