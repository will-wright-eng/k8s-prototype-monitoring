output "id" {
  description = "ID of the VPC"
  value       = digitalocean_vpc.main.id
}
output "name" {
  description = "Name of the VPC"
  value       = digitalocean_vpc.main.name
}
output "ip_range" {
  description = "IP range of the VPC"
  value       = digitalocean_vpc.main.ip_range
}
