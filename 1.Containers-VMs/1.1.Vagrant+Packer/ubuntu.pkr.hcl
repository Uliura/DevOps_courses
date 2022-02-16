
source "vagrant" "ubuntu" {
  add_force    = true
  communicator = "ssh"
  provider     = "virtualbox"
  source_path  = "ubuntu/bionic64"
}

build {
  sources = ["source.vagrant.ubuntu"]

}
