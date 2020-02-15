# Define the libvirt KVM hypervisor
provider "libvirt" {
  uri = "qemu:///system"
}

# Define the core network
resource "libvirt_network" "home-core-net" {
  name      = "home-core-net"
  addresses = ["10.0.0.0/16"]
  mode      = "nat"

  dns {
    enabled    = true
    local_only = false

    forwarders {
      address = "10.0.0.10"
      domain  = "xn--h1admmf5m.xn--d1aqf" # костић.дом
    }
  }

  dhcp {
    enabled = true
  }

  autostart = true
}

