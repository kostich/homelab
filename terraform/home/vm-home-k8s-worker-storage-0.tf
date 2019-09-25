data "template_file" "metadata-home-k8s-worker-storage-0" {
  template = "${file("${path.module}/configs/home-k8s-worker-storage-0/metadata.yaml")}"
}

data "template_file" "userdata-home-k8s-worker-storage-0" {
  template = "${file("${path.module}/configs/home-k8s-worker-storage-0/userdata.yaml")}"
}

resource "libvirt_cloudinit_disk" "home-k8s-worker-storage-0-cloudinit" {
  name = "home-k8s-worker-storage-0-cloudinit.iso"
  pool = "disk-drives"
  user_data = "${data.template_file.userdata-home-k8s-worker-storage-0.rendered}"
  meta_data = "${data.template_file.metadata-home-k8s-worker-storage-0.rendered}"
}

resource "libvirt_volume" "home-k8s-worker-storage-0-disk-system" {
  name = "home-k8s-worker-storage-0-disk-system.raw"
  pool = "disk-drives"
  source = "/var/lib/libvirt/images/install-media/fedora-cloud-base-30-amd64.raw"
  format = "raw"
}

resource "libvirt_volume" "home-k8s-worker-storage-0-disk-data" {
  name = "home-k8s-worker-storage-0-disk-data.raw"
  pool = "disk-drives"
  size = "53687091200" # 50 GB
  format = "raw"
}

resource "libvirt_domain" "home-k8s-worker-storage-0" {
  name = "home-k8s-worker-storage-0"
  memory = "4096"  # in MB
  vcpu = "4"
  autostart = false

  cloudinit = "${libvirt_cloudinit_disk.home-k8s-worker-storage-0-cloudinit.id}"

  network_interface {
    network_id = "${libvirt_network.home-core-net.id}"
    mac = "52:54:00:12:35:04"
    addresses = ["10.0.240.30"]
    wait_for_lease = true
  }

  disk {
       volume_id = "${libvirt_volume.home-k8s-worker-storage-0-disk-system.id}"
  }

  disk {
       volume_id = "${libvirt_volume.home-k8s-worker-storage-0-disk-data.id}"
  }
}