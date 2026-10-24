# oracle-always-free

Terraform setup for Oracle Cloud Infrastructure (OCI) Always Free resources in the **ap-hyderabad-1** home region.

## What it creates

| Service | Always Free usage |
|---|---|
| VCN | 1 public VCN + subnet + internet gateway |
| Compute | 2 instances (AMD `VM.Standard.E2.1.Micro` **or** Ampere A1 `VM.Standard.A1.Flex`) |
| Block Volume | 1 × 100 GB volume attached to the first instance (uses the remaining 100 GB of the 200 GB free allowance) |
| Object Storage | 1 bucket |
| Load Balancer | 1 Flexible LB pinned to 10 Mbps |
| Monitoring | Notification topic + CPU alarm |
| Vault | Virtual vault + software key + sample secret |
| Bastion | 1 bastion in the public subnet |
| Autonomous DB | 1 Always Free Autonomous Database (optional) |
| Email Delivery | 1 custom email domain + DKIM + approved sender (optional; requires DNS records) |

> By default AMD Micro instances are **not** used because the shape is often out of capacity. Set `use_amd_micro = true` to try it instead.
> Autonomous Database is also **disabled by default**. Set `enable_autonomous_db = true` and provide `autonomous_db_password` (minimum 12 characters) to create it.

## Quick start

1. Copy the example variables file and fill in your OCI credentials:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # edit terraform.tfvars
   ```

2. Generate or reuse an OCI API key under **Identity & Security → Users → API Keys**.

3. Initialize and apply:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. To avoid charges, keep the Flexible Load Balancer bandwidth at **10 Mbps min / 10 Mbps max** and the Ampere A1 total at **≤ 2 OCPUs / ≤ 12 GB memory**.

### Email Delivery DNS setup

If you set `email_domain_name`, after `terraform apply` you must add these DNS records at your domain registrar/DNS provider:

- **TXT record** for domain verification using the value shown in `email_domain_verification_id` output.
- **CNAME record** for DKIM using the value shown in `email_dkim_record` output.
- **TXT record** for SPF: `v=spf1 include:rp.oracleemaildelivery.com ~all`

Once DNS propagates, the domain status in OCI will become **ACTIVE** and the approved sender can be used.
