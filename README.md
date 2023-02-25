# About the project

This project will make setting up or updating Knime server easier. It's not done yeeeeeet!

## How to use

1. [install the docker engine](https://docs.docker.com/engine/install/ubuntu/) in your server if you haven't install.
2. download the docker image and run it

```bash

sudo docker build -t knime-server:4.16 .  

sudo docker run -p 8080:8080 -p 8443:8443  -it knime-server:4.16

```

## How to contribute

For now it install the Knime server 4.16, if you want install another version or new version and the docker image is not ready in [dockerhub](https://hub.docker.com/) yet, you can use the dockerfile to build your own.

If you want 

- change the knime server download url in the Dockerfile
- change the `auto-install.xml` to adapt the the new version of knime

