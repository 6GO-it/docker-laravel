# Docker file for Laravel image

This docker is crafted **specifically** for Laravel development only.

## Before you start

This docker image contains everything but Database, in order to include the database you need to manually create it and liking it.

## Reasons behind the exclusion of a Database

We think that the database should have its own container in order to maintain a certain degree of scalability.

## How to use this container

### For Contributors

Contributing to this project is pretty simple:

- Clone the repository
- Change directory into this repository
- Build the image manually using the cli command `docker build -t name-of-the-image .`. We suggest using names that are related to Laravel just to have a clear sight of the role of the container
- Once you have the image you can start as many container as you want
- To start a container you can use `docker run -d -v $(pwd):/app --name some-name name-of-the-image`

There are some basics scripts that help you build and run the container:

- Build using scripts `./scripts/build/build.sh name-of-the-image`
- Start container using scripts `./scripts/start-container/start-container.sh name-of-the-container name-of-the-images`

### For Developer (docker-compose)

If you are planning to use it for development you can check-out and example at `examples/docker-compose.yml` file example that we have included inside the repository

## Options and Configurations

The container itself is almost configuration agnostic but [since it depends on another container](https://github.com/webdevops/Dockerfile), it has few things to keep in mind

- The application root is set to `/app/public` because laravel has that as entry point
- The ports needed are `80 443 3306 6379`

## What is inside

You will find:

- Debian 8 as base OS
- Latest Nodejs and NPM
- Yarn as an alternative for NPM
- PHP 7.2 with necessary extensions and xDebug installed
- Nginx already configured to work on the exposed port 80
