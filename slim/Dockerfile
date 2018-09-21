FROM php:7.2-cli-stretch

LABEL maintainer=open-source@6go.it \
    vendor=6go.it \
    version=2.0.0

# Update OS and install necessary packages if missed
RUN apt-get update -y -qq \
    && apt-get -y -qq install apt-utils \
    autoconf automake build-essential \
    cmake git vim wget \
    libfreetype6-dev \
    libsdl2-dev \
    libtool \
    libicu-dev \
    libbz2-dev \
    libgmp-dev \
    libjpeg-dev \
    libmhash-dev \
    mercurial \
    pkg-config \
    texinfo

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    # Sanity check
    && composer -V

# Configure xDebug
RUN yes | pecl install -s xdebug-2.6.1 >> /dev/null \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

# Install PHP Extensions
RUN docker-php-source extract >> /dev/null \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/freetype2 --with-png-dir=/usr/include --with-jpeg-dir=/usr/include >> /dev/null \
    && docker-php-ext-install -j$(nproc) gd gmp intl opcache >> /dev/null \
    && docker-php-ext-enable xdebug opcache gd >> /dev/null

# Clean up all the mess done by installing stuff
RUN apt-get remove --purge -y software-properties-common \
    && apt-get autoremove -y \
    autoconf automake build-essential \
    cmake mercurial texinfo \
    && docker-php-source delete \
    && apt-get clean \
    && apt-get autoclean \
    && echo -n > /var/lib/apt/extended_states \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/man/?? \
    && rm -rf /usr/share/man/??_*

# Get the global composer file alongside with some interesting packages
COPY ../stubs/composer.json.stub /root/.composer/composer.json

# Copy up the source files for the root users
COPY ../stubs/.bashrc.stub /root/.bashrc
COPY ../stubs/.bash_aliases.stub /root/.bash_aliases

# Get a simple script if you want to bootstrap a fresh laravel project
COPY ../stubs/larastart.sh.stub /root/larastart.sh

RUN /bin/bash -c "source /root/.bashrc" \
    && chmod 755 /root/larastart.sh \ 
    && composer global update -qno

# Setup the entry entrypoint
WORKDIR /