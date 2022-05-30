# tt-azure-tmp
### How to
1. Clone repo
```
git clone https://github.com/nvzh/tt-azure-tmp.git
```
2. Save your login/password from Azure portal in some handy place
3. Build a Docker image
```
docker build -t $USER/terratrain:azure .
```
4. Run Docker container
```
docker run --rm -it $USER/terratrain:azure
```

### To Do
- Add MSR 3.0.x 
- Load Balancer doesn't route requests
- Add 50G disk to NSF node
- Adjust "t" script to work with Azure 

### Known Issues