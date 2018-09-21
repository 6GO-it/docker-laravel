# PHP 7.2 with Nginx

## Options and Configurations

The container itself is almost configuration agnostic but [since it depends on another container](https://hub.docker.com/r/webdevops/php-nginx/), it has few things to keep in mind

- The application root is set to `/app/public` because laravel has that as entry point
- The ports needed are `80 443 3306 6379`

## What is inside

You will find:

- Debian 9 as base OS
- Latest Nodejs and NPM
- Yarn as an alternative for NPM
- PHP 7.2 with necessary extensions and xDebug installed
- Nginx already configured to work on the exposed port 8
- A bunch of composer global packages ready
