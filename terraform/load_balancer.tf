# Starts with Serverless NEG (Helps the load balancer know "My backend is this Cloud run service")
resource "google_compute_region_network_endpoint_group" "cloud_run_neg" {
  name                  = "cloud-lab-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = "cloud-lab"
  }
}

# Backend Service (Load balancer configuration that says "Send requests to this backend")
resource "google_compute_backend_service" "cloud_run_backend" {
  name                  = "cloud-lab-backend"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.cloud_run_neg.id
  }
}

# URL map  (Any URL path goes to cloud-lab-backend [the cloud run services])
resource "google_compute_url_map" "cloud_lab_url_map" {
  name            = "cloud-lab-url-map"
  default_service = google_compute_backend_service.cloud_run_backend.id
}

#HTTP target proxy, no certificates. Connects incoming HTTP traffic to the URL map
resource "google_compute_target_http_proxy" "cloud_lab_http_proxy" {
  name    = "cloud-lab-http-proxy"
  url_map = google_compute_url_map.cloud_lab_url_map.id
}

# Forwarding Rule (Actually opens port 80 on the global IP)
resource "google_compute_global_forwarding_rule" "cloud_lab_http" {
  name                  = "cloud-lab-http-fr"
  target                = google_compute_target_http_proxy.cloud_lab_http_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.cloud_lab_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# HTTPS target proxy (Accept HTTPS traffic, use my certificate map for TLS, then use my existing URL map to decide where requests go)
resource "google_compute_target_https_proxy" "cloud_lab_https_proxy" {
  name    = "cloud-lab-https-proxy"
  url_map = google_compute_url_map.cloud_lab_url_map.id

  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.cloud_lab_cert_map.id}"
}

# HTTPS Forwarding Rule (traffic arriving at global_ip:443 goes to HTTPS target proxy)
resource "google_compute_global_forwarding_rule" "cloud_lab_https" {
  name                  = "cloud-lab-https-fr"
  target                = google_compute_target_https_proxy.cloud_lab_https_proxy.id
  port_range            = "443"
  ip_address            = google_compute_global_address.cloud_lab_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}