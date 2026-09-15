resource "google_certificate_manager_dns_authorization" "domain_auth" {
  name   = "cloud-lab-domain-auth"
  domain = var.domain
}

resource "google_certificate_manager_certificate" "cloud_lab_cert" {
  name = "cloud-lab-cert"

  managed {
    domains = [var.domain]

    dns_authorizations = [
      google_certificate_manager_dns_authorization.domain_auth.id
    ]
  }
}

resource "google_certificate_manager_certificate_map" "cloud_lab_cert_map" {
  name = "cloud-lab-cert-map"
}

resource "google_certificate_manager_certificate_map_entry" "cloud_lab_cert_entry" {
  name     = "cloud-lab-cert-entry"
  map      = google_certificate_manager_certificate_map.cloud_lab_cert_map.name
  hostname = var.domain

  certificates = [
    google_certificate_manager_certificate.cloud_lab_cert.id
  ]
}

