# tt-azure-tmp
### To Do
- Add MSR 3.0.x 
- Change outdated "azurerm_virtual_machine" resource to "azurerm_linux(windows)_virtual_machine"
- Get rid of "--force-minimums" flag in MKE config
- Load Balancer doesn't route requests
- Add tags
- Add 50G disk to NSF node
- Re-write variable names 

### Known Issues
- Windows VM fails to spin up if cluster has MSR worker (Azure module)
- WinRM without IP in launchpad.yaml (AWS module)