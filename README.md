# Docker file for Laravel image

This docker is crafted for Laravel development only, but if you are brave you can use for any PHP Project.

## Before start

This docker image contains everything but Database, in order to include the database you need to manually create it, well soft of
because we have already included an automated script that is able to do everything: piece of cake!

* Why keep the database outside? Because we think that the database should have its own container in order to maintain a certain degree of
scalability.

## How to use this container

Using this docker is pretty simple:

- Clone the repository
- Change directory into this repository
- Build the image manually using the cli command `docker build -t name-of-the-image .`. We suggest using names that are related to Laravel just to have a clear sight of the role of the container
- Once you have the image you can start as many container as you want
- To start a container you can use `docker -d -v $(pwd):/app --name some-name name-of-the-image`

## Options and configurations

The container itself is almost configuration agnostic but, since it depends on another container, it has few things to keep in mind

- The application root is set to `/app`
- The ports needed are `80 443 3306 6379`

## What is inside

You will find:

- Debian 8 as base OS
- Latest Nodejs and NPM
- Yarn as an alternative for NPM
- PHP 7.0 with necessary extensions and xDebug installed
- Apache already configured to work on the exposed port 80