terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
}


############# Varables #############
# Proxmox variables
variable "px_endpoint" { type = string }
variable "px_user" { type = string }
variable "px_password" { type = string }
variable "px_target_node" { type = string }
variable "px_tls" { type = bool }

# Cluster variables
variable "cluster_name" { type = string }
variable "cluster_desc" { type = string }
variable "cluster_clone" { type = string }
variable "cluster_agent" { type = number }
variable "cluster_os_type" { type = string }
variable "cluster_scsihw" { type = string }
variable "cluster_storage" { type = string }

variable "cluster_ssh" { type = string }
variable "cluster_subnet" { type = string }
variable "cluster_gw" { type = string }
variable "cluster_start_ip" { type = number }
variable "cluster_cidr" { type = number }
variable "cluster_tag" { type = number }

variable "cluster_master_count" { type = number }
variable "cluster_master_memory" { type = number }
variable "cluster_master_cores" { type = number }
variable "cluster_master_dsize" { type = number }

variable "cluster_worker_count" { type = number }
variable "cluster_worker_memory" { type = number }
variable "cluster_worker_cores" { type = number }
variable "cluster_worker_dsize" { type = number }
####################################

provider "proxmox" {

      pm_tls_insecure = var.px_tls
      pm_api_url = "${var.px_endpoint}"
      pm_user = "${var.px_user}"
      pm_password = "${var.px_password}"
}


resource "proxmox_vm_qemu" "master" {
    count = var.cluster_master_count
    name = "${var.cluster_name}-masterTest-${count.index + 1}"
    desc = "${var.cluster_desc} - masterTest node ${count.index + 1}"
    tags = "${var.cluster_name}_kubernetes_master_node_${count.index + 1}"
    target_node = "${var.px_target_node}"
    clone = "${var.cluster_clone}"
    agent = var.cluster_agent
    os_type = "${var.cluster_os_type}"
    memory = var.cluster_master_memory
    scsihw = "${var.cluster_scsihw}"

    cpu {
        cores = var.cluster_master_cores
        sockets = 1
        type = "x86-64-v2-AES"
    }

    disks {
            ide {
                ide0 {
                    cloudinit {
                        storage = "${var.cluster_storage}"
                    }
                }
            }
            virtio {
                virtio0 {
                    disk {
                        size            = var.cluster_master_dsize
                        storage         = "${var.cluster_storage}"
                        iothread        = true
                        discard         = true
                        format          = "qcow2"
                    }
                }
            }
        }

    # Setup the network interface and assign a vlan tag: 256
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr10"
        tag = var.cluster_tag
    }

    # Setup the ip address using cloud-init.
    boot = "order=virtio0"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=${var.cluster_subnet}.${var.cluster_start_ip + count.index}/${var.cluster_cidr},gw=${var.cluster_gw}"
    ssh_user = "root"
    sshkeys = var.cluster_ssh
}

resource "proxmox_vm_qemu" "worker" {
    count = var.cluster_worker_count
    name = "${var.cluster_name}-worker-${count.index + 1}"
    desc = "${var.cluster_desc} - worker node ${count.index + 1}"
    tags = "${var.cluster_name}_kubernetes_worker_node_${count.index + 1}"
    target_node = "${var.px_target_node}"
    clone = "${var.cluster_clone}"
    agent = var.cluster_agent
    os_type = "${var.cluster_os_type}"
    memory = var.cluster_worker_memory
    scsihw = "${var.cluster_scsihw}"

    cpu {
        cores = var.cluster_worker_cores
        sockets = 1
        type = "x86-64-v2-AES"
    }

    disks {
            ide {
                ide0 {
                    cloudinit {
                        storage = "${var.cluster_storage}"
                    }
                }
            }
            virtio {
                virtio0 {
                    disk {
                        size            = var.cluster_worker_dsize
                        storage         = "${var.cluster_storage}"
                        iothread        = true
                        discard         = true
                        format          = "qcow2"
                    }
                }
            }
        }

    # Setup the network interface and assign a vlan tag: 256
    network {
        id = 0
        model = "virtio"
        bridge = "vmbr10"
        tag = var.cluster_tag
    }

    # Setup the ip address using cloud-init.
    boot = "order=virtio0"
    # Keep in mind to use the CIDR notation for the ip.
    ipconfig0 = "ip=${var.cluster_subnet}.${var.cluster_start_ip + count.index + var.cluster_master_count}/${var.cluster_cidr},gw=${var.cluster_gw}"

    sshkeys = var.cluster_ssh
}

output "master_ips" {
    value = [for instance in proxmox_vm_qemu.master : instance.default_ipv4_address ]
}

output "worker_ips" {
    value = proxmox_vm_qemu.worker[*].default_ipv4_address
}