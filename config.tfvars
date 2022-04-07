# Azure Info
location="germanywestcentral"                       # choose your region eg eastus, germanywestcentral, etc
name="onovozhylov"                         # Something to identify your instances
caseNo="12345678"                       # you can specify your case no here (optional)

# Use "UbuntuServer" for 16.04-LTS/18.04-LTS and "0001-com-ubuntu-server-focal" for 20_04-lts-gen2
# Use "RHEL" or "centos?"
os_name="RHEL"  # offer
# For ubuntu 16.04-LTS,18.04-LTS etc. 
# For RHEL use 79-gen2
os_version="79-gen2"   # sku

# Managers Info
manager_count="1"
manager_instance_type="Standard_D2s_v3"

# # MSR  Info
msr_count="0"
msr_version_3="0"
msr_instance_type="Standard_D2s_v3"
nfs_backend="0"                 # 1 for true and 0 for fals

# # Workers Info
worker_count="0"
worker_instance_type="Standard_D2s_v3"
win_worker_count="0"
# win_worker_instance_type="c4.xlarge"

# MKE MSR MCR info
# Please change only the following informations if you want to use `t deploy cluster`.
mcr_version="20.10.10"          # Please use specific minor engine version.
mke_version="3.5.1"             # MKE Version
msr_version="2.9.1"             # MSR Version
image_repo="docker.io/mirantis" #For older version use docker.io/docker , specifically use :
# docker.io/docker for images up-to: 3.1.14, 3.2.7, 3.3.1  (taken from https://hub.docker.com/r/docker/ucp/tags?page=3&ordering=name )
# docker.io/mirantis for images : 3.1.15+, 3.2.8+, 3.3.2+  (taken from https://hub.docker.com/r/mirantis/ucp/tags?page=1&ordering=name )
#---------------------------------------------------------------------------------------------------------------------------
# Check Again Please

# Following lines are autogenerated so please don't change

# publicKey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+p9n1NPk+eoXX6GrkPM78vtBOUDtoNz9Gq8H+KRprfpMcB/RSRZeqlBIArgDZyGgITR/IodUn6z5k2lyGbTOmBhvRnf7Z4JykAQfEtlrXHMnPSaYAEaKN6FmC/iHyGM2Dhj6brNr4KbuN2zadc1kNGghcptr2v+SD4EUgq85JAqnuZQQ+tgIjz4NDpWXLEcKVhAJcBxQjTHnSjlo7xHCEIuOn3W3V8PLdrUHwptpM5goPPdlKWXsIwZ2n8UuzMFDbuXmvBn9nx+QE6ZApdCJ7t3zPW8M5zufaOstfzvVwETbDf7jUK6ulzrxaroi1IGsOP4clyotqGcYHh7ldVfVPhS9ptivpOixlF8JY+zoksP+R6I78bNpFxB230+HyFndZfqVSxDVosUObRfdCSFb3DdRmueKuxA51ES6/lJMXuFzvriAHP+a6TQpAziCPxBBQHOlC25el3XI/tFTzM00rIKKu5ZTJYNjGgPFqDdttb7QeGJEFYxIjLz+ZN5bYnz7oOzu56+32xr+EkFV3IFAH45fnsOOy/GmRXcHQnMbpk8HvVTjuhcJwVa30I3OtHL9KfwGXi+TGuhv7m3CX/uXFTHFPU2yWqgVS77QI0ki4TqEQvO8hLbnN/lb/Elj7Xa2vvtMvx/jXFUqgwaQGm+w5Q0cKZZKMv1qRvq4bQrJsqQ== root@b9ca5a48db8e"