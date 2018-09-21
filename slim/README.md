# PHP 7.2 cli on Debian Stretch Slim

## Options and Configurations

The container itself is almost configuration agnostic but [since it depends on another container](https://github.com/docker-library/php/tree/88189f016803224152e3b1d96b11a573b3762559/7.2/stretch/cli), it has few things to keep in mind

- No ports are exposed
- It lacks of web server
- Node is missing to keep the package slim

## What is inside

You will find:

- Debian 9 as base OS
- PHP 7.2 with necessary extensions and xDebug installed
- A bunch of composer global packages ready
