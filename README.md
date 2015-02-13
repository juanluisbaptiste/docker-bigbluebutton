# docker-bigbluebutton

Unofficial BigBlueButton 0.81 docker image. This repository contains the Dockerfile and all other files needed to build the docker image. 

More info about BigBlueButton at: http://bigbluebutton.org/


### About this image and the Dockerfile:

This image is based on Ubuntu 10.04 x86_64, which is the [officially supported O.S](https://code.google.com/p/bigbluebutton/wiki/InstallationUbuntu#Before_You_Install). for BigBlueButton 0.81. The Dockerfile follows the [official installation instructions](https://code.google.com/p/bigbluebutton/wiki/InstallationUbuntu#Installing_BigBlueButton_0.81) found on BigblueButton's documentation, plus some fixes needed to successfully boot the container. 

You can find a prebuilt docker image from [Docker Hub](https://registry.hub.docker.com/u/juanluisbaptiste/bigbluebutton/). To be able to use it, first it has to be pulled off from the Hub:

    sudo docker pull juanluisbaptiste/bigbluebutton:latest
  
Or you can build it as described below. Then you can run a container from it, also see instructions below on how to do it.

This is still an **alpha version** use it at your own risk. There is still some stuff about how to handle the different services that conform the BigBlueButton app inside the docker container that need to be improved.

### Build Instructions
After you clone this repository you need to build the image with the `docker` command like this:

    cd docker-bigbluebutton
    sudo docker build -t bbb_0.81 .

### How to launch the container
This `docker` command will launch a new BigBlueButton container:

    sudo docker run -d --name bbb bbb_0.81

This will launch the container without exposing any of BigBlueButton's service ports, so you will need to access the container's private IP adress. To be able to access the container externally (or from the docker host machine), BigBlueButton IP address configuration needs to be set to an external hostname that can be resolved, using the env variable `SERVER_NAME`. Start the container like this:

    sudo docker run -d --name bbb -p 80:80 -p 9123:9123 -p 1935:1935 -e SERVER_NAME=meeting.somedomain.com bbb_0.81

Then you can access the container externally (provided `SERVER_NAME` resolves to a public IP address) using $`SERVER_NAME`. The hostname set in `SERVER_NAME` must point to the docker host machine. If you can't use the same host ports (ie: you already have a web server running on port 80) you can start the container using other ports:

    sudo docker run -d --name bbb -p 80:8080 -p 9123:91230 -p 1935:19350 -e SERVER_NAME=meeting.somedomain.com bbb_0.81

And configure a reverse proxy server (like nginx) to go to the BigBlueButton's container private IP address and the specified port in the docker run command when accessing `SERVER_NAME`. Or even easier use a nginx container and link it to the BigBlueButton container.

You can attach to the container while it starts and wait for it to finish, then take the IP address from the end of the output. To attach to the container run the following `docker` command:

    sudo docker attach --sig-proxy=false bbb

### How to access the container
After you attach to the container you will see an output like the following one telling you how to access the container:

    *******************************************
    Use this address to access your 
    BigBlueButton container: 
    
    meeting.somedomain.com
    
    *******************************************

Access that address from your browser and you will get to the demo page.

### TODO
* Improve the way BigBlueButton services start using supervisord/systemd instead of using a custom script (TODO for 0.9.0 bbb version).
