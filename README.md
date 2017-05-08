# Docker file for Laravel image

This docker is crafted for Laravel development only, but if you are brave you can use for any PHP Project.

## Before start

This docker image contains everything but Database, in order to include the database you need to manually create it, well soft of
because we have already included an automated script that is able to do everything: piece of cake!

* Why keep the database outside? Because we think that the database should have its own container in order to maintain a certain degree of
scalability.

## How to use

Using this docker is pretty simple

- Clone the repository
- Change directory into this repository
- Build the image using the script in `scripts\build\build.*` (choose the right script of your OS)  this will create the **laravel** image
- Alternatevly you can build the image manually using the cli command `docker build -t name-of-the-image .`
- Once you have the image you can start as many container as you want
- To start a container you can run the script located in `scripts\start-container\start-container.*` this will create the right database image as well as the laravel container

## Options and configurations



## What is inside

You will find:

- Debian 8 as base OS
- Latest Nodejs and NPM
- Yarn as an alternative for NPM
- PHP v7.1 with necessary extensions and xDebug installed
- Apache already configured to work on the exposed port 80