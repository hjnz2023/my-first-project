output "repository_url" {
  value = module.hello_service.reopsitory_url
}

output "lb_address" {
  value = module.load_balancer.ingress_address.address
}