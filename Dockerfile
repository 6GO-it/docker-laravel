FROM webdevops/php-nginx:7.2

LABEL maintainer=open-source@6go.it \
    vendor=6go.it \
    version=1.1.10

# Set up some basic global environment variables
ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
ENV DEBIAN_FRONTEND noninteractive

# Get Nodejs and NPM, alongside YarnPkg, in order to be able to work with front end stuff
# BE AWARE the command bash - is risky but we trust the source
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install all the necessary libraries
RUN apt-get update -y -qq \
    && apt-get -y -qq install \
    apt-utils autoconf automake \
    build-essential cmake git \
    libass-dev libfreetype6-dev \
    libsdl2-dev libtheora-dev \
    libtool libva-dev \
    libvdpau-dev libvorbis-dev \
    libxcb1-dev libxcb-shm0-dev \
    libxcb-xfixes0-dev libx264-dev \
    libjpeg62-turbo-dev libmcrypt-dev \
    libpng-dev libbz2-dev \
    libgmp-dev libmhash-dev \
    libicu-dev libpq-dev \ 
    libvpx-dev libfdk-aac-dev \
    libmp3lame-dev libopus-dev \
    mercurial pkg-config \
    texinfo zlib1g-dev

# Install necessary softwares
RUN apt-get install -y -qq \
    vim wget yasm \
    re2c file yarn jpegoptim \
    optipng pngquant  gifsicle

# Install node related global packages
RUN npm install -g svgo

# Install ffmpeg
RUN mkdir -p ~/ffmpeg_sources \
    && export MAKEFLAGS="-j4"

RUN cd ~/ffmpeg_sources \
    && wget -q http://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2 \
    && tar xjf nasm-2.13.03.tar.bz2 \
    && cd nasm-2.13.03 \
    && ./autogen.sh > /dev/null \
    && ./configure --prefix="$HOME/ffmpeg_build" --bindir="/usr/local/bin" > /dev/null \
    && make > /dev/null \
    && make install > /dev/null 

RUN cd ~/ffmpeg_sources \
    && hg clone https://bitbucket.org/multicoreware/x265 -q \
    && cd x265/build/linux \
    && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source \
    && make > /dev/null \
    && make install > /dev/null 

RUN cd ~/ffmpeg_sources \
    && wget -q -O ffmpeg-snapshot.tar.bz2 http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 \
    && tar xjf ffmpeg-snapshot.tar.bz2 \
    && cd ffmpeg \
    && PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="$HOME/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$HOME/ffmpeg_build/include" \
    --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
    --extra-libs="-lpthread -lm" \
    --bindir="/usr/local/bin" \
    --enable-gpl \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    > /dev/null \
    && make > /dev/null \
    && make install > /dev/null \
    && hash -r

# Symbolic link necessary for php extensions
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/

# Since PHP 7.2 mcrypt is not enabled by default
# so we need to include it manually
# Please see https://stackoverflow.com/a/47673183/1202367
RUN yes | pecl install -s mcrypt-1.0.1

# Configure xDebug
RUN yes | pecl install -s xdebug-2.6.1 \
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

# Clean up all the mess done by installing stuff
RUN apt-get autoremove --purge -y software-properties-common \
    autoconf automake  build-essential cmake mercurial texinfo \
    && apt-get clean \
    && apt-get autoclean \
    && echo -n > /var/lib/apt/extended_states \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/man/?? \
    && rm -rf /usr/share/man/??_*

# Updating PHP ini and Nginx configuration with custom ones
COPY configs/php/98-webdevops-custom.ini /usr/local/etc/php/conf.d/98-webdevops.ini
COPY configs/nginx/10-general-custom.conf /opt/docker/etc/nginx/vhost.common.d/10-general.conf

# Add sample workers for supervisor 
COPY configs/supervisor/horizon-worker-template.conf /opt/docker/etc/supervisor.d/horizon-worker-template.conf
COPY configs/supervisor/laravel-worker-template.conf /opt/docker/etc/supervisor.d/laravel-worker-template.conf

# Get the global composer file alongside with some interesting packages
COPY stubs/composer/global-composer.json /root/.composer/composer.json

# Copy up the source files for the root users
COPY stubs/bash/.bashrc /root
COPY stubs/bash/.bash_aliases /root

# Get a simple script if you want to bootstrap a fresh laravel project
COPY stubs/larastart.sh /root/scripts/larastart.sh

RUN /bin/bash -c "source /root/.bashrc" \
    && chmod 755 /root/scripts/larastart.sh \ 
    && composer global update -qno

# Expose ports
EXPOSE 80 443 3306 6379

# Setup the entry entrypoint
WORKDIR /app
