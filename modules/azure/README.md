# tt-azure-tmp
### How to
1. Clone repo
`git clone https://github.com/nvzh/tt-azure-tmp.git`
2. Save your login/password from Azure portal in some handy place (the same that you use for Google Acc)
3. Create RBAC credentials
```
az login
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/d8cf16d8-db67-4e89-bcbe-d6316fce6378"
``` 
4. Ask me to give you a "t-commandline-new.bash", update it with your RBAC credentials, and put into ./bin folder.
5. Build a Docker image
`docker build -t $USER/terratrain:azure .`
6. Run Docker container
`docker run --rm -it $USER/terratrain:azure`
7. Set "cloud_provider" variable to azure in "config" file.

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