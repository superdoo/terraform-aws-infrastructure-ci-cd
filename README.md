
# Terraform AWS Infrastructure CI/CD 🚀

This project sets up a **CI/CD pipeline** using **Jenkins** to automate **Terraform** infrastructure provisioning on **AWS**. It demonstrates Infrastructure as Code (IaC) principles, secure credential handling, and cloud automation engineering best practices.

---

## 🧱 Project Goals

- ✅ Automate AWS infrastructure provisioning with Terraform  
- ✅ Use Jenkins to run `terraform init` and `plan` on Git push  
- ❌ Skipped `terraform apply` in the pipeline due to the `when` condition (this can be modified in the Jenkinsfile)  
- ✅ Secure credentials using Jenkins credential store  
- ✅ Keep GitHub repo clean of binaries and sensitive files

---

## 🧭 Architecture Diagram

```plaintext
+--------------------------+
|     GitHub Repo         |
|  terraform-aws-infra    |
+-----------+--------------+
            |
            |  (Push Event)
            v
+--------------------------+
|        Jenkins CI/CD     |
|  (Terraform Pipeline)    |
|  - terraform init        |
|  - terraform plan        |
|  - terraform apply (skipped) |
+-----------+--------------+
            |
            |  (If applied)
            v
+--------------------------+
|        AWS Cloud         |
|  - EC2 instance          |
|  - VPC, Subnet, SG       |
+--------------------------+
```

---

## 🛠️ Project Structure

```plaintext
terraform-aws-infrastructure-ci-cd/
│
├── main.tf                # Terraform AWS config (EC2, VPC, etc.)
├── variables.tf           # Terraform input variables
├── outputs.tf             # Terraform output (e.g., instance_public_ip)
├── Jenkinsfile            # Declarative Jenkins pipeline script
├── .gitignore             # Ignores .terraform, state files, etc.
└── README.md              # This file
```

---

## 🔐 Credential Management

Credentials are securely stored in Jenkins as:

- **ID**: `my-aws-credentials-id`
- **Type**: AWS Credentials (Access Key ID and Secret Key)

This avoids hardcoding credentials or committing them to version control.

---

## 🔁 Jenkins Pipeline Overview

| Stage            | Description                           |
|------------------|---------------------------------------|
| **Checkout**     | Pulls code from GitHub repo           |
| **Terraform Init** | Initializes working directory        |
| **Terraform Plan** | Generates and shows execution plan  |
| **Terraform Apply** | *Skipped* due to pipeline condition |

> ⚠️ **Note:** The `apply` stage is skipped in the current setup using a `when` condition. To enable it, modify the `Jenkinsfile` to allow automatic apply based on branch, approval, or build parameters.

---

## ✅ Output (If Applied)

If `terraform apply` is run manually or conditionally in Jenkins, the following output is expected:

```hcl
Outputs:

instance_public_ip = "3.25.120.47"   # Example IP after provisioning
```

---

## 📌 Best Practices Followed

- `.terraform` folder excluded from Git using `.gitignore`
- Large provider binaries **not committed** (preventing GitHub push errors)
- Use of **Jenkins Credentials Plugin** for secret management
- Separation of pipeline logic (`Jenkinsfile`) from infrastructure code (`*.tf`)

---

## 📷 Screenshots

<details>
<summary>✅ Jenkins Build Logs</summary>

```bash
Started by user Michael Barreras
Obtained Jenkinsfile from GitHub
Cloning repository...
Checking out Revision...
Terraform init completed successfully
Terraform plan shows 9 resources to be added
Apply skipped due to conditional
```
</details>

---

## 📘 How to Apply Manually

To manually apply the changes after Jenkins runs the plan:

```bash
terraform apply "tfplan"
```

Or, adjust your `Jenkinsfile` to include:

```groovy
when {
    branch 'main'
}
```

under the `apply` stage to enable auto-apply on main branch pushes.
