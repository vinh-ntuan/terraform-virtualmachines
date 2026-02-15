# terraform-virtualmachines
This is a project to practice terraform.

This spawns
1. An Azure virtual network
2. A custom number of VMs connected to this virtual network, each with a Public IP (see variables). After spawning, they will ping each other round-robin-style


Due to dev purposes, port 22 is open on all VMs, please be careful!
# How to use:
Add `subscription_id` to the `azure_rm` provider in `providers.tf`, i.e:
```yaml
provider "azurerm" {
  features {}
  subscription_id = <insert-subscription-id-here>
}
```
Then, execute:
```bash
terraform plan # View changes
terraform apply # Deploy 
```

# Input
| Variable | Type | Default | Description |
| --- | --- | --- | --- |
| **`vm_count`** | `number` | `3` | The total number of Virtual Machines to deploy. Must be between **2 and 100**. |
| **`admin_username`** | `string` | `azureuser` | The username used for administrative access to the VMs. |
| **`vm_configs`** | `list(object)` | 3 configs with Debian 12 | A list of configurations for each VM (size, publisher, sku, etc.). The list length **must match** `vm_count`. |

# Output 
| Name | Description | 
| --- | --- | 
| **`vm_details`** | A list containing the name, admin credentials, and IP addresses (Public/Private) for each created VM. |
| **`ping_results`** | Results of the VMs pinging each other |
