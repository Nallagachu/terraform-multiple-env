
# Terraform Multiple Environments Example

[](https://www.google.com/search?q=https://github.com/Nallagachu/terraform-multiple-env/blob/main/LICENSE)
[](https://releases.hashicorp.com/terraform/)
[](https://aws.amazon.com/)

This repository demonstrates a common and recommended pattern for managing multiple infrastructure environments (e.g., `dev`, `stage`, `prod`) using a single set of Terraform configuration files, primarily leveraging `*.tfvars` files.

## Table of Contents

  * [About the Project](https://www.google.com/search?q=%23about-the-project)
  * [Key Concepts Demonstrated](https://www.google.com/search?q=%23key-concepts-demonstrated)
  * [Getting Started](https://www.google.com/search?q=%23getting-started)
      * [Prerequisites](https://www.google.com/search?q=%23prerequisites)
      * [Repository Structure](https://www.google.com/search?q=%23repository-structure)
      * [Configuration](https://www.google.com/search?q=%23configuration)
  * [Usage](https://www.google.com/search?q=%23usage)
      * [Deploying the `dev` Environment](https://www.google.com/search?q=%23deploying-the-dev-environment)
      * [Deploying the `stage` Environment](https://www.google.com/search?q=%23deploying-the-stage-environment)
      * [Deploying the `prod` Environment (Caution\!)](https://www.google.com/search?q=%23deploying-the-prod-environment-caution)
      * [Destroying Environments](https://www.google.com/search?q=%23destroying-environments)
  * [Why Separate `tfvars` Files? (Recommended Approach)](https://www.google.com/search?q=%23why-separate-tfvars-files-recommended-approach)
  * [Workspaces vs. `tfvars` Files (Clarification)](https://www.google.com/search?q=%23workspaces-vs-tfvars-files-clarification)
  * [Important Note on State Locking](https://www.google.com/search?q=%23important-note-on-state-locking)
  * [Contributing](https://www.google.com/search?q=%23contributing)
  * [License](https://www.google.com/search?q=%23license)
  * [Contact](https://www.google.com/search?q=%23contact)
  * [Acknowledgments](https://www.google.com/search?q=%23acknowledgments)

## About the Project

In infrastructure-as-code, it's common to require different environments for development, testing, and production, each with potentially different resource sizes, counts, or specific configurations. This repository provides a clear example of how to achieve this using Terraform's input variables and `tfvars` files.

The core idea is to define your infrastructure once in generic Terraform (`.tf`) files and then use environment-specific variable files (`.tfvars`) to customize the deployment for `dev`, `stage`, or `prod`.

**What this example deploys:**

(Assuming a simple AWS example, e.g., EC2 instance, VPC, S3 bucket. Adjust as per your actual `main.tf` content.)

This example deploys a simple set of AWS resources, configurable via variables, allowing you to quickly provision:

  * An EC2 Instance (with configurable type and name)
  * A VPC (with a configurable CIDR block)
  * An S3 Bucket (with a configurable name)

Each environment will provision its own isolated set of these resources with values specific to that environment.

## Key Concepts Demonstrated

  * **Terraform Input Variables:** Defining flexible parameters in `variables.tf`.
  * **`*.tfvars` Files:** Providing specific values for variables per environment (`dev.tfvars`, `stage.tfvars`, `prod.tfvars`).
  * **Remote State Management (S3 Backend):** Securely storing Terraform state files in AWS S3 for collaborative team use. Each environment gets its own isolated state file.
  * **Resource Tagging:** Using environment-specific tags for better resource organization and cost allocation.
  * **DRY (Don't Repeat Yourself) Principle:** Reusing the same core `.tf` code across multiple environments.

## Getting Started

To get this example up and running on your AWS account, follow these steps.

### Prerequisites

  * **Terraform CLI:** [v1.x.x or higher](https://developer.hashicorp.com/terraform/downloads) installed.
  * **AWS CLI:** Configured with credentials that have permissions to create EC2, VPC, S3, and IAM resources in your desired region.
  * **An S3 Bucket for Terraform State:** You need to create an S3 bucket *manually* once before running Terraform. This bucket will store your Terraform state files.
      * **Recommended Naming Convention:** `your-unique-terraform-state-bucket-name` (e.g., `nallagachu-terraform-states-12345`).
      * Ensure the bucket has [versioning enabled](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html) for state history.

### Repository Structure

```
.
├── environments/
│   ├── dev.tfvars        # Variable values for the development environment
│   ├── prod.tfvars       # Variable values for the production environment
│   └── stage.tfvars      # Variable values for the staging environment
├── main.tf               # Main Terraform configuration: defines resources
├── variables.tf          # Defines input variables used in main.tf
├── outputs.tf            # Defines output values after deployment
├── backend.tf            # Configures the S3 remote backend
├── .gitignore            # Specifies files to ignore in Git
└── README.md             # This file
```

### Configuration

1.  **Clone the Repository:**

    ```bash
    git clone https://github.com/Nallagachu/terraform-multiple-env.git
    cd terraform-multiple-env
    ```

2.  **Update `backend.tf`:**
    Open `backend.tf` and **replace `"your-unique-terraform-state-bucket"`** with the actual name of the S3 bucket you created for Terraform state.

    ```terraform
    # backend.tf
    terraform {
      backend "s3" {
        bucket         = "your-unique-terraform-state-bucket" # <--- UPDATE THIS!
        key            = "${var.environment}/terraform.tfstate"
        region         = "us-east-1" # Or your desired AWS region
        encrypt        = true
      }
    }
    ```

3.  **Review `*.tfvars` Files:**
    Examine the `environments/dev.tfvars`, `environments/stage.tfvars`, and `environments/prod.tfvars` files. These files contain the specific values for variables like `instance_type`, `vpc_cidr_block`, `instance_count`, and the `environment` name itself.

    **Example `environments/dev.tfvars`:**

    ```hcl
    environment    = "dev"
    instance_type  = "t2.micro"
    vpc_cidr_block = "10.0.0.0/16"
    instance_count = 1
    bucket_name    = "nallagachu-dev-bucket-12345" # Ensure this is globally unique!
    ```

    **Adjust values in these files as needed for your specific deployment requirements, especially `bucket_name` to ensure uniqueness across environments and globally within S3.**

4.  **Initialize Terraform:**
    Run `terraform init` to download providers and configure the S3 backend. This must be done once per root module.

    ```bash
    terraform init
    ```

## Usage

You will use the `-var-file` flag with `terraform plan` and `terraform apply` to specify which environment's variables to use.

### Deploying the `dev` Environment

1.  **Plan the `dev` deployment:**

    ```bash
    terraform plan -var-file=environments/dev.tfvars
    ```

    Review the proposed changes to ensure they match your expectations for the development environment.

2.  **Apply the `dev` deployment:**

    ```bash
    terraform apply -var-file=environments/dev.tfvars --auto-approve
    ```

    This will provision the resources defined in `main.tf` using the values from `dev.tfvars`. The state will be stored in `s3://your-unique-terraform-state-bucket/dev/terraform.tfstate`.

### Deploying the `stage` Environment

1.  **Plan the `stage` deployment:**

    ```bash
    terraform plan -var-file=environments/stage.tfvars
    ```

    Observe how the plan reflects different values (e.g., `instance_type`, `instance_count`, `vpc_cidr_block`) based on `stage.tfvars`.

2.  **Apply the `stage` deployment:**

    ```bash
    terraform apply -var-file=environments/stage.tfvars --auto-approve
    ```

    This will provision a *separate, isolated set* of resources for the staging environment. Its state will be stored in `s3://your-unique-terraform-state-bucket/stage/terraform.tfstate`.

### Deploying the `prod` Environment (Caution\!)

**Exercise extreme caution when deploying to production environments.** Always double-check your `plan` output and ensure you are using the correct `tfvars` file.

1.  **Plan the `prod` deployment:**

    ```bash
    terraform plan -var-file=environments/prod.tfvars
    ```

    Carefully review the production plan.

2.  **Apply the `prod` deployment:**

    ```bash
    terraform apply -var-file=environments/prod.tfvars --auto-approve
    ```

    This will provision your production infrastructure, completely separate from `dev` and `stage`. Its state will be stored in `s3://your-unique-terraform-state-bucket/prod/terraform.tfstate`.

### Destroying Environments

To tear down an environment, simply use `terraform destroy` with the corresponding `tfvars` file:

  * **Destroy `dev`:**

    ```bash
    terraform destroy -var-file=environments/dev.tfvars --auto-approve
    ```

  * **Destroy `stage`:**

    ```bash
    terraform destroy -var-file=environments/stage.tfvars --auto-approve
    ```

  * **Destroy `prod` (EXTREME CAUTION\!):**

    ```bash
    terraform destroy -var-file=environments/prod.tfvars --auto-approve
    ```

## Why Separate `tfvars` Files? (Recommended Approach)

This pattern is widely considered the best practice for managing distinct, long-lived environments because it provides:

  * **Clear Separation of Concerns:** Environment-specific configurations are neatly organized in dedicated files.
  * **Version Control:** `tfvars` files are typically version-controlled, allowing you to track changes to environment parameters over time.
  * **Reduced Risk:** Explicitly specifying the `-var-file` reduces the chance of accidentally applying changes to the wrong environment compared to relying on implicit context.
  * **Scalability:** Easily add new environments by creating a new `tfvars` file.
  * **Auditability:** It's easy to see exactly what values are being used for any given environment.

## Workspaces vs. `tfvars` Files (Clarification)

It's important to clarify the difference between using `tfvars` files for distinct environments and Terraform Workspaces.

**Terraform Workspaces:**

  * Are designed for managing **multiple, independent state files** for a **single Terraform configuration** within the **same backend**.
  * **Best Use Cases:** Ephemeral environments (e.g., creating a temporary environment for a feature branch or pull request review) or developer sandboxes.
  * **Why NOT for Dev/Stage/Prod:** They make it harder to manage significant configuration differences between long-lived environments and can increase the risk of accidental changes due to easy switching.

**`*.tfvars` Files (as demonstrated here):**

  * Are used to pass **different variable values** to the **same Terraform configuration** to provision distinct infrastructure for different purposes.
  * **Best Use Cases:** Managing distinct, long-lived environments like `dev`, `stage`, and `prod`, where the core infrastructure structure is similar but parameters differ.

**In essence: Use `tfvars` files for `dev`/`stage`/`prod`. Reserve workspaces for temporary, parallel deployments of the *exact same* configuration.**

## Important Note on State Locking

This configuration uses an S3 bucket for remote state storage. While S3 provides versioning for state files, it **does not inherently provide state locking** to prevent concurrent Terraform operations from corrupting the state.

**Implications without State Locking:**

  * **Concurrent Operation Risk:** If multiple users or automated pipelines (e.g., CI/CD) attempt to run `terraform apply` on the *same environment's state file* simultaneously, it can lead to race conditions. This might result in:
      * **State Corruption:** The state file becomes inconsistent, leading to errors and inaccurate representation of your infrastructure.
      * **Resource Duplication/Deletion Errors:** Terraform might create duplicate resources or fail to manage existing ones correctly.
      * **"Phantom" Resources:** Resources that exist in your cloud provider but are not reflected in your state file, or vice-versa.
  * **"Last Write Wins" Issue:** The last `terraform apply` operation to complete successfully will overwrite any partial updates from other concurrent operations.

**Recommendations for Collaborative or Production Environments:**
For any collaborative work, or for production environments where state consistency is paramount, it is **highly recommended to enable state locking**. The most common and robust way to achieve this with an S3 backend is to also use an **AWS DynamoDB table** for locking. DynamoDB provides a simple, consistent key-value store that Terraform can use to acquire a lock before performing operations.

While this example focuses on pure S3 for state, be mindful of this limitation in a team setting.

## Contributing

Contributions are welcome\! If you have suggestions for improvements or find issues, please feel free to:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/your-feature`).
3.  Make your changes and commit them.
4.  Push to the branch.
5.  Open a Pull Request with a clear description of your changes.

## License

This project is open-sourced under the [MIT License](https://www.google.com/search?q=https://github.com/Nallagachu/terraform-multiple-env/blob/main/LICENSE).

## Contact

If you have any questions or feedback, you can reach out to:

Nallagachu - [GitHub Profile](https://www.google.com/search?q=https://github.com/Nallagachu)

## Acknowledgments

  * HashiCorp Terraform documentation for excellent resources on best practices.
  * The wider Terraform community for continuous learning and inspiration.

-----