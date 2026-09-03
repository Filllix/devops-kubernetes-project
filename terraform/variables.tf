variable "ansible_ssh_public_key" {
  description = "Public SSH key used by Ansible to access the management host"
  type        = string
  sensitive   = true
}

variable "ansible_ssh_cidr" {
  description = "CIDR allowed to access the management host through SSH"
  type        = string
}
