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
      private_key = "${file("/Create-Openstack-Instance-Bootstrapweb/id_rsa")}"
    }

    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
      "echo '[username]' | sudo tee /var/www/html/index.html"
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
