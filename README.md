# CIPROXMOX

Provision Proxmox VMs using Terraform — simple, repeatable, and declarative.

---

## 📌 Getting Started

### 1️⃣ Configure Environment Variables

1. Copy the `terraform.tfvars.tmp` file as a starting point:

   ```bash
   cp terraform.tfvars.tmp terraform.tfvars
   ```

2. Update `terraform.tfvars` with your own values:

   ```hcl
   # Proxmox connection
   px_endpoint   = "https://<PX_IP>:8006/api2/json"
   px_user       = "PX_USER"
   px_password   = "PX_PASSWORD"
   px_target_node = "PX_NODE"
   px_tls        = true

   # Cluster details
   cluster_name      = "newtest"
   cluster_desc      = "Test cluster for Terraform and Proxmox"
   cluster_clone     = "ct108"
   cluster_storage   = "local-ssd"
   cluster_agent     = 1
   cluster_os_type   = "cloud-init"
   cluster_scsihw    = "virtio-scsi-pci"

   # Network
   cluster_subnet    = "10.5.6"   # Subnet without last octet
   cluster_start_ip  = 32
   cluster_gw        = "10.5.6.10"
   cluster_cidr      = 24
   cluster_tag       = 92
   cluster_ssh       = "SSH_KEY"

   # Masters
   cluster_master_count  = 2
   cluster_master_memory = 4096
   cluster_master_cores  = 2
   cluster_master_dsize  = 40

   # Workers
   cluster_worker_count  = 2
   cluster_worker_memory = 4096
   cluster_worker_cores  = 2
   cluster_worker_dsize  = 40
   ```

---

### 2️⃣ Provision the Cluster

1. **See what will be created/changed:**

   ```bash
   terraform plan
   ```

2. **Apply the changes to create your infrastructure:**

   ```bash
   terraform apply
   ```

---

## ✅ Notes

* Make sure your Proxmox user has the required API permissions.
* Double-check network, storage, and template settings for your environment.
