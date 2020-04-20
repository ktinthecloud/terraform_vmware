
terraform {
  backend "remote" {
    organization = "kevintodd"
    token = "__TerraCloud__"
    workspaces {
      name = "vsphere"
    }
  }
}


provider "vsphere" {
    user           = "administrator@vsphere.local"
    password       = "__vCenter__"
    vsphere_server = "vcsa1.lab.com"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "SanDiego"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore2"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Lab"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "DPortGroup"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "packerimage"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  firmware         = "bios"
  annotation	   = "My Server"

  num_cpus = 2
  memory   = 2048
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
	#data.vsphere_virtual_machine.template.network_interface_types[0]
  }


  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      windows_options {
        computer_name = "terraform-test"
        admin_password = "__VMLocalAdmin__"
      }

      network_interface {
        ipv4_address = "192.168.0.226"
        ipv4_netmask = 24
		dns_server_list = ["192.168.0.201"]
      }

      ipv4_gateway = "192.168.0.1"
    }
  }
#Define connection info for running ConfigureRemotingForAnsible.ps1 on newly built VM
    connection {
    type     = "winrm"
    user     = "Administrator"
    password = "__VMLocalAdmin__"
    host     = "192.168.0.226"
     }

#Copy the script to the VM
  provisioner "file" {
		source      = "ConfigureRemotingForAnsible.ps1"
		destination = "C:/temp/ConfigureRemotingForAnsible.ps1"
		}

 #Configure VM for Ansible 
	provisioner "remote-exec" {
		inline = [
			"powershell.exe C:/temp/ConfigureRemotingForAnsible.ps1 -EnableCredSSP",
		]
  }
}