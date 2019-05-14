resource "openstack_compute_instance_v2" "instance" {
  name             = "[username]"
  image_name       = "[choose_image_in_openstack]"
  flavor_name      = "[flavor_kind]"
  key_pair         = "[key-name]"
  security_groups  = ["default"]
  network {
    uuid = "[uuid on your network]"
  }
}

resource "openstack_networking_floatingip_v2" "floating_ip" {
  pool = "[name of external net]"
}

resource "openstack_compute_floatingip_associate_v2" "floating_ip" {
  floating_ip = "${openstack_networking_floatingip_v2.floating_ip.address}"
  instance_id = "${openstack_compute_instance_v2.instance.id}"
