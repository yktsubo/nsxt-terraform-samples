# Configure the VMware vSphere Provider
provider "vsphere" {
  vsphere_server = "${var.vsphere_vcenter}"
  user = "${var.vsphere_user}"
  password = "${var.vsphere_password}"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_datastore" "datastore" {
  name          = "${var.vsphere_datastore}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.vsphere_template}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_resourcepool}"  
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "vlan887" {
  name          = "A_887_Management"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "ls_k8s_pod" {
  name          = "ls-k8s-pod"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "k8s-master1" {
  name             = "k8s-master1"
  num_cpus = 2
  memory   = 2048
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"  
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
  nested_hv_enabled = true
  
  network_interface {
    network_id   = "${data.vsphere_network.vlan887.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id   = "${data.vsphere_network.ls_k8s_pod.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[1]}"
  }
  
  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "k8s-master1"
        domain    = "ytsuboi.local"
        time_zone = "JST"
      }

      network_interface {
        ipv4_address = "10.16.187.71"
        ipv4_netmask = "24"
      }
      network_interface {
        ipv4_address = "192.168.91.71"
        ipv4_netmask = "25"
      }
      dns_server_list = ["10.127.1.131"]
      dns_suffix_list =  ["ytsuboi.local"]
      ipv4_gateway = "192.168.91.1"
    }
  }
}

resource "vsphere_virtual_machine" "k8s-master2" {
  name             = "k8s-master2"
  num_cpus = 2
  memory   = 2048
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"  
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
  nested_hv_enabled = true
  
  network_interface {
    network_id   = "${data.vsphere_network.vlan887.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id   = "${data.vsphere_network.ls_k8s_pod.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[1]}"
  }
  
  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "k8s-master2"
        domain    = "ytsuboi.local"
        time_zone = "JST"
      }

      network_interface {
        ipv4_address = "10.16.187.72"
        ipv4_netmask = "24"
      }
      network_interface {
        ipv4_address = "192.168.91.72"
        ipv4_netmask = "25"
      }
      dns_server_list = ["10.127.1.131"]
      dns_suffix_list =  ["ytsuboi.local"]
      ipv4_gateway = "192.168.91.1"
    }
  }
}

resource "vsphere_virtual_machine" "k8s-master3" {
  name             = "k8s-master3"
  num_cpus = 2
  memory   = 2048
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"  
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
  nested_hv_enabled = true
  
  network_interface {
    network_id   = "${data.vsphere_network.vlan887.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id   = "${data.vsphere_network.ls_k8s_pod.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[1]}"
  }
  
  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "k8s-master3"
        domain    = "ytsuboi.local"
        time_zone = "JST"
      }

      network_interface {
        ipv4_address = "10.16.187.73"
        ipv4_netmask = "24"
      }
      network_interface {
        ipv4_address = "192.168.91.73"
        ipv4_netmask = "25"
      }
      dns_server_list = ["10.127.1.131"]
      dns_suffix_list =  ["ytsuboi.local"]
      ipv4_gateway = "192.168.91.1"
    }
  }
}

resource "vsphere_virtual_machine" "k8s-node1" {
  name             = "k8s-node1"
  num_cpus = 2
  memory   = 2048
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"  
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
  nested_hv_enabled = true
  
  network_interface {
    network_id   = "${data.vsphere_network.vlan887.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id   = "${data.vsphere_network.ls_k8s_pod.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[1]}"
  }
  
  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "k8s-node1"
        domain    = "ytsuboi.local"
        time_zone = "JST"
      }

      network_interface {
        ipv4_address = "10.16.187.74"
        ipv4_netmask = "24"
      }
      network_interface {
        ipv4_address = "192.168.91.74"
        ipv4_netmask = "25"
      }
      dns_server_list = ["10.127.1.131"]
      dns_suffix_list =  ["ytsuboi.local"]
      ipv4_gateway = "192.168.91.1"
    }
  }
}

resource "vsphere_virtual_machine" "k8s-node2" {
  name             = "k8s-node2"
  num_cpus = 2
  memory   = 2048
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"  
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"
  nested_hv_enabled = true
  
  network_interface {
    network_id   = "${data.vsphere_network.vlan887.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  network_interface {
    network_id   = "${data.vsphere_network.ls_k8s_pod.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[1]}"
  }
  
  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "k8s-node2"
        domain    = "ytsuboi.local"
        time_zone = "JST"
      }

      network_interface {
        ipv4_address = "10.16.187.75"
        ipv4_netmask = "24"
      }
      network_interface {
        ipv4_address = "192.168.91.75"
        ipv4_netmask = "25"
      }
      dns_server_list = ["10.127.1.131"]
      dns_suffix_list =  ["ytsuboi.local"]
      ipv4_gateway = "192.168.91.1"
    }
  }
}
