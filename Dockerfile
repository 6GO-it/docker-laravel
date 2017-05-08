FROM webdevops/php-apache:debian-8-php7

MAINTAINER  "Claudio Ludovico Panetta <ludo@6go.it>"

# Set up some basic global environment variables
ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
ENV DEBIAN_FRONTEND noninteractive

# Get nodejs and npm
# in order to be able to work
# on the front end development
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
    && apt-get install -y nodejs

# Install Yarn package as an alternative
RUN curl -s https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
	&& apt-get update \
	&& apt-get install yarn

# Clean up all the mess
# done by installing stuff
RUN apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# Get the global composer file alongside with
# some interesting packages
COPY configs/composer/composer.json /root/.composer/composer.json
RUN composer global update -q -n -o

# Build up the source files for the root users
COPY configs/.bashrc /root
COPY configs/.bash_aliases /root
RUN /bin/bash -c "source /root/.bashrc"

# Get a simple script to initialize the current laravel project
COPY configs/larastart.sh /root/larastart.sh
RUN chmod 755 /root/larastart.sh

# Expose ports
EXPOSE 80 443 3306 6379

# Setup the entry entrypoint
WORKDIR /app
