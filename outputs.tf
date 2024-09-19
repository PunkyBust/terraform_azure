output "public_ip_fqdn" {
  description = "The FQDN of the public IP address."
  value       = azurerm_public_ip.lb-public-ip.fqdn
}

# ... Add more outputs as needed.