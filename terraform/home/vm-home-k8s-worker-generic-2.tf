data "template_file" "metadata-home-k8s-worker-generic-2" {
  template = "${file("${path.module}/configs/home-k8s-worker-generic-2/metadata.yaml")}"
}

data "template_file" "userdata-home-k8s-worker-generic-2" {
  template = "${file("${path.module}/configs/home-k8s-worker-generic-2/userdata.yaml")}"
}

resource "libvirt_cloudinit_disk" "home-k8s-worker-generic-2-cloudinit" {
  name = "home-k8s-worker-generic-2-cloudinit.iso"
  pool = "disk-drives"
  user_data = "${data.template_file.userdata-home-k8s-worker-generic-2.rendered}"
  meta_data = "${data.template_file.metadata-home-k8s-worker-generic-2.rendered}"
}

resource "libvirt_volume" "home-k8s-worker-generic-2-disk-system" {
  name = "home-k8s-worker-generic-2-disk-system.raw"
  pool = "disk-drives"
  source = "/var/lib/libvirt/images/install-media/fedora-cloud-base-31-amd64.raw"
  format = "raw"
}

resource "libvirt_domain" "home-k8s-worker-generic-2" {
  name = "home-k8s-worker-generic-2"
  memory = "10368"  # in MB
  vcpu = "8"
  autostart = false

  cloudinit = "${libvirt_cloudinit_disk.home-k8s-worker-generic-2-cloudinit.id}"

  network_interface {
    network_id = "${libvirt_network.home-core-net.id}"
    mac = "52:54:00:12:35:03"
    addresses = ["10.0.240.22"]
    wait_for_lease = true
  }

  disk {
       volume_id = "${libvirt_volume.home-k8s-worker-generic-2-disk-system.id}"
  }
}