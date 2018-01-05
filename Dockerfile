FROM webdevops/php-nginx:7.2

LABEL maintainer=open-source@6go.it \
    vendor=6go.it \
    version=1.1.4

# Set up some basic global environment variables
ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
ENV DEBIAN_FRONTEND noninteractive

# Get nodejs and npm
# in order to be able to work
# on the front end development
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -

# Add Yarn package as an alternative
RUN curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install all the stuff
RUN apt-get update -qq \
    && apt-get install -y -qq vim \
    apt-utils \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libbz2-dev \
    libgmp-dev \
    libmhash-dev \
    libicu-dev \
    libpq-dev \    
    re2c \
    file \
    yarn

# Symbolic link necessary for php extensions
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/

# Clean up all the mess done by installing stuff
RUN apt-get remove --purge -y software-properties-common \
    && apt-get autoremove -y \
    && apt-get clean \
    && apt-get autoclean \
    && echo -n > /var/lib/apt/extended_states \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/man/?? \
    && rm -rf /usr/share/man/??_*

# Since PHP 7.2 mcrypt is not enabled by default
# so we need to include it manually
# Please see https://stackoverflow.com/a/47673183/1202367
RUN yes | pecl install -s mcrypt-1.0.1

# Configure xDebug
RUN yes | pecl install -s xdebug-2.6.0beta1 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

# Install PHP Extensions
RUN docker-php-source extract \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/freetype2 --with-png-dir=/usr/include --with-jpeg-dir=/usr/include \
    && docker-php-ext-install -j$(nproc) gmp intl opcache pdo_pgsql pgsql \
    && docker-php-ext-enable xdebug opcache gd mcrypt \
    && docker-php-source delete

# Updating PHP ini and Nginx configuration with custom ones
COPY configs/php/98-webdevops-custom.ini /usr/local/etc/php/conf.d/98-webdevops.ini
COPY configs/nginx/10-general-custom.conf /opt/docker/etc/nginx/vhost.common.d/10-general.conf

# Get the global composer file alongside with some interesting packages
COPY configs/composer/composer.json /root/.composer/composer.json
RUN composer global update -qno

# Build up the source files for the root users
COPY configs/bash/.bashrc /root
COPY configs/bash/.bash_aliases /root
RUN /bin/bash -c "source /root/.bashrc"

# Get a simple script if you want to bootstrap a fresh laravel project
COPY configs/laravel/larastart.sh /root/larastart.sh
RUN chmod 755 /root/larastart.sh

# Expose ports
EXPOSE 80 443 3306 6379

# Setup the entry entrypoint
WORKDIR /app
