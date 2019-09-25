## What

This repository contains code used to bootstrap my homelab.

### Deploying VMs via Terraform
    # last tested with Terraform 0.12.9
    # we need the terraform plugin for libvirt
    go get -v github.com/dmacvicar/terraform-provider-libvirt
    # create .terraform.d folder and copy over plugin to it
    mkdir -p ~/.terraform.d/ && mv $GOPATH/bin/terraform* ~/.terraform.d/
    # Initialize and deploy the terraform plan
    cd homelab/terraform/home && terraform init && terraform apply
    # Due to the lack of support for disk resizing in the terraform plugin
    # go to the /var/lib/libvirt/images/disk-drives and manually adjust the
    # drive sizes via qemu-img command
    qemu-img resize ./<disk-file-name>.raw 20G

### Deploying services to VMs via Ansible
    # last tested with Ansible 2.8.4 (python 3.7.4)
    cd homelab/ansible
    ansible-playbook -i environments/home/hosts playbooks/provisioning/setup-infra.yaml
