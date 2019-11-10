data "template_file" "metadata-home-mirror-0" {
  template = "${file("${path.module}/configs/home-mirror-0/metadata.yaml")}"
}

data "template_file" "userdata-home-mirror-0" {
  template = "${file("${path.module}/configs/home-mirror-0/userdata.yaml")}"
}

resource "libvirt_cloudinit_disk" "home-mirror-0-cloudinit" {
  name = "home-mirror-0-cloudinit.iso"
  pool = "disk-drives"
  user_data = "${data.template_file.userdata-home-mirror-0.rendered}"
  meta_data = "${data.template_file.metadata-home-mirror-0.rendered}"
}

resource "libvirt_volume" "home-mirror-0-disk-system" {
  name = "home-mirror-0-disk-system.raw"
  pool = "disk-drives"
  source = "/var/lib/libvirt/images/install-media/fedora-cloud-base-31-amd64.raw"
  format = "raw"
}

resource "libvirt_domain" "home-mirror-0" {
  name = "home-mirror-0"
  memory = "1056"  # in MB
  vcpu = "1"
  autostart = false

  cloudinit = "${libvirt_cloudinit_disk.home-mirror-0-cloudinit.id}"

  network_interface {
    network_id = "${libvirt_network.home-core-net.id}"
    mac = "52:54:00:12:36:02"
    addresses = ["10.0.0.20"]
    wait_for_lease = true
  }

  disk {
       volume_id = "${libvirt_volume.home-mirror-0-disk-system.id}"
  }
}