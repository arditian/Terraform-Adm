resource "openstack_compute_instance_v2" "instance" {
  name            = "${var.name}"
  image_name      = "${var.image}"
  flavor_name     = "${var.flavor}"
  key_pair        = "${var.keypair}"
  security_groups = ["default"]
  network {
    uuid = "${var.network}"
  }

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = "[your-deafult-image-user]"
      private_key = "${file("/Run-github-app/id_rsa")}"
    }

    inline = [
      "sudo yum clean all",
      "sudo yum -y update",
      "sudo yum -y install epel-release",
      "sudo yum -y install nginx",
      "sudo yum -y install git",
      "sudo yum -y install httpd",
      "sudo firewall-cmd --permanent --add-port=80/tcp",
      "sudo firewall-cmd --permanent --add-port=443/tcp",
      "sudo firewall-cmd --reload",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start nginx",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/gabrielecirulli/2048 /var/www/html",
      "sudo systemctl restart httpd"
    ]
  }

}

resource "openstack_networking_floatingip_v2" "floating_ip" {
  pool = "[name of external network]"
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.floating_ip.address}"
  instance_id = "${openstack_compute_instance_v2.instance.id}"
}
