# Data source used to grab the TLS certificate for GitHub
data "tls_certificate" "tfc_certificate" {
  url = "https://github.com"
}