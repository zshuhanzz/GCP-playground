output "global_ip" {
  value = google_compute_global_address.cloud_lab_ip.address
}

output "dns_auth_record_name" {
  value = google_certificate_manager_dns_authorization.domain_auth.dns_resource_record[0].name
}

output "dns_auth_record_type" {
  value = google_certificate_manager_dns_authorization.domain_auth.dns_resource_record[0].type
}

output "dns_auth_record_data" {
  value = google_certificate_manager_dns_authorization.domain_auth.dns_resource_record[0].data
}