
# step 2
## Create syft docker volume:
```bash
sudo docker volume create scan-target
```
## clone project into volume
```bash
cd downloader
docker build -t downloader .
docker run -v scan-target:/scan-target downloader https://github.com/home-assistant/core.git
```

## Running the scanner image in a container with a volume mount
```bash
sudo docker build -t scanner:latest .
sudo docker run -v scan-target:/scan-target scanner:latest
```


# Step 3
## deploy dependencytrack
I reduced the memory resources of dependencytrack to 2048MB in the .yml

```bash
curl -LO https://dependencytrack.org/docker-compose.yml
docker-compose up -d
```
# Step 4
## scan and upload results
Build the scanner container
```bash
cd scanner
docker build -t scanner .
```
Join the network and scan. 
```bash
docker run --network dependencytrack_default --rm -it -v scan-target:/scan-target -v $(pwd):/scan-output scanner /scan-target dtrack-apiserver:8080/api/v1/bom $API_KEY
```
