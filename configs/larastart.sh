#!/usr/bin/env bash
# Get into the directory where the application will live
cd /app
# Download the code from the official repository
# or update the current vendor repository
if [ -d "vendor" ]; then
  composer update -o
else
  composer install -o
fi
# Generate a new key instance in order to have a clean
# environment
php artisan key:generate
# Remove node_modules because fuck you
rm -rf node_modules
# Install necessary dependencies
if ! [ -x "$(command -v yarn)" ]; then
  npm install -g cross-env gulp webpack webpack-dev-server
  if [ -f "package.json" ]; then
    npm install
    npm run dev
  fi
else
  yarn global add cross-env gulp webpack webpack-dev-server
  if [ -f "package.json" ]; then
    yarn
    yarn upgrade
    yarn run dev
  fi
fi

