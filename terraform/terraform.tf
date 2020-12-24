variable "do_token" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
    token = var.do_token
}

// Create droplet
resource "digitalocean_droplet" "guwudangin" {
    name = "guwudangin"
    image = "ubuntu-20-04-x64"
    region = "sgp1"
    size = "s-1vcpu-1gb"
    private_networking = true
    ssh_keys = [var.ssh_fingerprint]
}

//Configure Domain
resource "digitalocean_domain" "guwudangin-domain" {
    name = "guwudangin.me"
    ip_address = digitalocean_droplet.guwudangin.ipv4_address
}

// Add records for www and api
resource "digitalocean_record" "www" {
    domain = digitalocean_domain.guwudangin-domain.name
    type = "A"
    name = "www"
    value = digitalocean_domain.guwudangin-domain.ip_address
}

resource "digitalocean_record" "api" {
    domain = digitalocean_domain.guwudangin-domain.name
    type = "A"
    name = "api"
    value = digitalocean_domain.guwudangin-domain.ip_address
}

//Configure firewall
resource "digitalocean_firewall" "guwudangin-firewall" {
    name = "guwudangin-firewall"
    droplet_ids = [ digitalocean_droplet.guwudangin.id ]

    inbound_rule {
      protocol = "tcp"
      port_range = "22"
      source_addresses = ["0.0.0.0/0"]
    }

    inbound_rule {
      protocol = "tcp"
      port_range = "80"
      source_addresses = [ "0.0.0.0/0" ]
    }

    inbound_rule {
      protocol = "tcp"
      port_range = "443"
      source_addresses = [ "0.0.0.0/0" ]
    }

    outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }

}

// Display output after droplet created
output "ip" {
  value = digitalocean_droplet.guwudangin.ipv4_address
}