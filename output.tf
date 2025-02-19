# --- root/output.tf


output "load_balancer_endpoint" {
  value = module.loadbalancing.lb_endpoint
}

output "instances" {
  value     = { for i in module.compute.instance : i.tags.Name => "${i.public_ip}: ${module.compute.tg_port}" }
  sensitive = true
}

output "kubeconfig" {
  value = [ for i in module.compute.instance: "export KUBECONFIG=../k3s-${i.tags.Name}.yaml"]
}