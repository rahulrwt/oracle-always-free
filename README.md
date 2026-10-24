# oracle-always-free

Terraform setup for Oracle Cloud Infrastructure (OCI) **Always Free** resources in the **ap-hyderabad-1** home region.

## What it creates

| Service | Always Free usage |
|---|---|
| VCN | 1 public VCN + subnet + internet gateway |
| Compute | 2 × AMD `VM.Standard.E2.1.Micro` **or** 1 × Ampere A1 `VM.Standard.A1.Flex` (2 OCPU / 12 GB) |
| Block Volume | 1 × 100 GB volume attached to the first instance (uses the remaining 100 GB of the 200 GB free allowance) |
| Object Storage | 1 private bucket |
| Load Balancer | 1 Flexible LB pinned to 10 Mbps |
| Monitoring | Notification topic + CPU alarm |
| Vault | Virtual vault + software key + sample secret |
| Bastion | 1 bastion in the public subnet |
| Autonomous DB | 1 Always Free Autonomous Database (optional) |
| Email Delivery | 1 custom email domain + DKIM + approved sender (optional; requires DNS records) |

> **Defaults:** AMD Micro instances are **not** used because the shape is often out of capacity. Autonomous Database and Email Delivery are also **disabled by default**.

---

## Prerequisites

1. An Oracle Cloud Free Tier / Always Free account with **home region** set to `ap-hyderabad-1`.
2. [Terraform](https://developer.hashicorp.com/terraform/downloads) installed locally.
3. An SSH key pair for the compute instances.

   ```bash
   ssh-keygen -t rsa -b 4096 -C "oci-free-tier" -f ~/.ssh/oci_free_tier
   ```

---

## Step 1 — Gather OCI credentials

Terraform needs an API key to talk to OCI. You only need to do this once.

### 1.1 Get your Tenancy OCID

1. Log in to the [OCI Console](https://cloud.oracle.com).
2. Click the **Profile** menu (top-right) and select **Tenancy: <your-tenancy-name>**.
3. Copy the **OCID** value.

### 1.2 Get your User OCID

1. Go to **Identity & Security → Users**.
2. Click your user name.
3. Copy the **OCID** value.

### 1.3 Create an API key

1. In your user details page, click **API Keys → Add API Key**.
2. Choose **Generate API Key Pair**.
3. Download the **private key** and save it securely, for example:

   ```bash
   mkdir -p ~/.oci
   mv ~/Downloads/<private-key>.pem ~/.oci/oci_api_key.pem
   chmod 600 ~/.oci/oci_api_key.pem
   ```

4. Click **Add**.
5. Copy the **Fingerprint** shown in the dialog (e.g., `aa:bb:cc:...`).

### 1.4 Get your Compartment OCID

For a personal Free Tier account, use the **root compartment** OCID.

1. Open the **Profile** menu and select **Tenancy: <your-tenancy-name>**.
2. Under **Object Storage Settings**, copy the **Object Storage Namespace** if needed, but the Terraform code reads it automatically.
3. Go to **Identity & Security → Compartments**, click the root compartment, and copy its **OCID**.

### 1.5 Confirm your home region

1. Open the **Region** dropdown in the console header.
2. The region marked with **(Home)** should be **Hyderabad** (`ap-hyderabad-1`).

---

## Step 2 — Configure Terraform variables

1. Copy the example file:

   ```bash
   cd /Users/rahul/Projects/oracle-always-free
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with the values you collected:

   ```hcl
   tenancy_ocid     = "ocid1.tenancy.oc1..xxxxxxxxx"
   user_ocid        = "ocid1.user.oc1..xxxxxxxxx"
   fingerprint      = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
   private_key_path = "~/.oci/oci_api_key.pem"
   region           = "ap-hyderabad-1"
   compartment_ocid = "ocid1.compartment.oc1..xxxxxxxxx"
   ssh_public_key   = "ssh-rsa AAAA..."
   ```

   For `ssh_public_key`, paste the contents of `~/.ssh/oci_free_tier.pub`.

3. Review the optional service toggles:

   ```hcl
   use_amd_micro         = false   # set true only if VM.Standard.E2.1.Micro is available
   enable_autonomous_db  = false   # set true + provide autonomous_db_password to create DB
   email_domain_name     = ""      # set to yourdomain.com to enable Email Delivery
   notification_email    = ""      # email for CPU alarm notifications
   ```

---

## Step 3 — Initialize and apply

```bash
terraform init
terraform plan
terraform apply
```

`terraform apply` will show the resources it plans to create. Type `yes` to proceed.

---

## Step 4 — Read the outputs

After apply, useful values are printed:

```bash
terraform output
```

Examples:

- `instance_public_ips` — SSH into the instances.
- `load_balancer_ip_addresses` — access the load balancer over HTTP.
- `email_dkim_record` and `email_domain_verification_id` — required DNS records.

---

## Step 5 — Email Delivery DNS setup (only if you set `email_domain_name`)

Add these DNS records at your domain registrar/DNS provider:

1. **TXT record** for domain verification using the `email_domain_verification_id` output.
2. **CNAME record** for DKIM using the `email_dkim_record` output.
3. **TXT record** for SPF:

   ```text
   v=spf1 include:rp.oracleemaildelivery.com ~all
   ```

Once DNS propagates, the domain status in OCI becomes **ACTIVE** and the approved sender can be used.

---

## Always Free limits to watch

- **Compute:** 2 × `VM.Standard.E2.1.Micro` **or** up to 2 OCPU / 12 GB total of `VM.Standard.A1.Flex`.
- **Block Volume:** 200 GB total across boot and block volumes. This config uses the full 200 GB.
- **Load Balancer:** Flexible shape must stay at **10 Mbps min / 10 Mbps max**.
- **Object Storage:** 20 GB combined across Standard / Infrequent Access / Archive.
- **Email Delivery:** 3,000 emails / month.
- **Autonomous DB:** 2 free instances max (1 OCPU / 20 GB each).

All Always Free resources must be created in your tenancy **home region** (`ap-hyderabad-1`).

---

## Cleaning up

To remove everything created by this project:

```bash
terraform destroy
```

---

## Alternative: environment variables for credentials

Instead of putting credentials in `terraform.tfvars`, you can export them:

```bash
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..xxxxxxxxx"
export TF_VAR_user_ocid="ocid1.user.oc1..xxxxxxxxx"
export TF_VAR_fingerprint="aa:bb:cc:..."
export TF_VAR_private_key_path="~/.oci/oci_api_key.pem"
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..xxxxxxxxx"
export TF_VAR_ssh_public_key="$(cat ~/.ssh/oci_free_tier.pub)"
```

Then run `terraform plan` and `terraform apply` as usual.
