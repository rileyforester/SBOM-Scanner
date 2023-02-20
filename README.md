# Step 1
## Install Syft, CycloneDX, and the CycloneDX python langauge package

Syft is a Software Composition Analysis tool that allows users to analyze and inspect the packages and dependencies
that are included in the image.  It's output will include details on the packages and dependencies installed, a list of vulnerabilities found in the image, information on the CVE, and suggestions for remediation.  This is referred to as a Software Bill of Materials (SBOM).

CycloneDX is the most widely used format for standardized SBOMs. We will also install the CycloneDX Python langauge package so we can 
scan a Python application.  I chose Home Assistant - a python-based home automation platform.
We will eventually send this data via an http PUT request to the dependency-track API. 

Dependency-Track is another SCA tool with a GUI. It is similar to Blackduck. By integrating Syft with Dependency-Track we will gain more
detailed information about vulnerabilities and license issues associated with the dependencies.  

# step 2
## Create syft docker volume:

Volumes are used for persistent data.  You can compare it to your hard-drive as opposed to RAM.  

```bash
docker volume create scan-target
```
## clone python project into volume
```bash
cd downloader
docker build -t downloader .
docker run -v scan-target:/scan-target downloader https://github.com/home-assistant/core.git
```


## Running the scanner image in a container with a volume mount
```bash
docker build -t scanner:latest .
docker run -v scan-target:/scan-target scanner:latest
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
cd ../scanner
docker build -t scanner .
```
Join the network and scan. 
```bash
docker run --network dependencytrack_default --rm -it -v scan-target:/scan-target -v $(pwd):/scan-output scanner /scan-target dtrack-apiserver:8080/api/v1/bom $API_KEY
```
