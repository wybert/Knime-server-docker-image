# About the project

This project will make setting up or updating Knime server easier. It's not done yeeeeeet!

## How to use

You can pull from [dockerhub](https://hub.docker.com/repository/docker/happybeetles/knime_server/general) and run it, or you can clone this repo and build a docker image by yourself. For both you need install [Docker](https://docs.docker.com/engine/install/ubuntu/).

### Use from dockerhub

```bash
sudo docker run -p 8080:8080 -p 8443:8443  -it knime_server:4.16
```

## Build and test

Clone this repo and `cd` the this repo folder, then

```bash
sudo docker build -t knime-server:4.16 .  
sudo docker run -p 8080:8080 -p 8443:8443  -it knime_server:4.16
# mannuly start the Knime server and Knime executor in this docker

```

## Todo

- [ ] Get license work
- [ ] Get ready for distributed exectors 
- [ ] Get Geospatil extension work
- [ ] Get Python and R enviroment work

## How to contribute

For now it install the Knime server 4.16, if you want install another version or new version and the docker image is not ready in [dockerhub](https://hub.docker.com/) yet, you can use the dockerfile to build your own.

If you want 

- change the knime server download url in the Dockerfile
- change the `auto-install.xml` to adapt the the new version of knime

