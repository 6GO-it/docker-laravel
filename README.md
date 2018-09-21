# Docker file for Laravel image

This docker is crafted for Laravel development only, but if you are brave you can use for any PHP Project.

## Before start

This docker image contains everything but Database, in order to include the database you need to manually create it and liking it.

## No database inside

We think that the database should have its own container in order to maintain a certain degree of scalability.

## How to use this container

Using this docker is pretty simple:

- Clone the repository
- Change directory into this repository
- Build the image manually using the cli command `docker build -t name-of-the-image /path/to/Dockefile`. We suggest using names that are related to Laravel just to have a clear sight of the role of the container
- Once you have the image you can start as many container as you want
- To start a container you can use `docker run -d -v $(pwd):/app --name some-name name-of-the-image`

There are some basics scripts that help you build and run the container:

- Build using scripts `./scripts/build/build.sh name-of-the-image /path/to/DockerFile`
- Start container using scripts `./scripts/start-container/start-container.sh name-of-the-container name-of-the-images`

## Options and Configurations

Please see the ReadMe for each type of Docker image.
