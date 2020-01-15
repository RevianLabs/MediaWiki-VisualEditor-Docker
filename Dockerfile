FROM php:7.1-apache

# System Dependencies.
RUN apt-get update && apt-get install -y \
		git \
		libcurl4-openssl-dev \
		curl \
		imagemagick \
		libicu-dev \
	--no-install-recommends && rm -r /var/lib/apt/lists/*

# Install the PHP extensions we need
RUN docker-php-ext-install mbstring mysqli opcache intl curl

# Install the default object cache.
RUN pecl channel-update pecl.php.net \
	&& pecl install apcu-5.1.8 \
	&& docker-php-ext-enable apcu

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# SQLite Directory Setup
RUN mkdir -p /var/www/data \
	&& chown -R www-data:www-data /var/www/data

# Version
ENV MEDIAWIKI_MAJOR_VERSION 1.32
ENV MEDIAWIKI_BRANCH REL1_32
ENV MEDIAWIKI_VERSION 1.32.1
ENV MEDIAWIKI_SHA512 597af44ba140a50b4dfec9dd1a81db1c96e6672f33870ad15d9be875c4a7109eff57034e10762c45c47bad4afdfe27b96949dd6dd4bea24db6ea54bafd80c376

# MediaWiki setup
RUN curl -fSL "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" -o mediawiki.tar.gz \
	&& echo "${MEDIAWIKI_SHA512} *mediawiki.tar.gz" | sha512sum -c - \
	&& tar -xz --strip-components=1 -f mediawiki.tar.gz \
	&& rm mediawiki.tar.gz \
&& chown -R www-data:www-data extensions skins cache images

RUN git clone -b "${MEDIAWIKI_BRANCH}" https://gerrit.wikimedia.org/r/p/mediawiki/extensions/VisualEditor.git ./extensions/VisualEditor

WORKDIR /var/www/html/extensions/VisualEditor

RUN git submodule update --init

# Parsoid setup
WORKDIR /usr/lib/

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
	apt-get install -y nodejs && \	
	git clone https://gerrit.wikimedia.org/r/p/mediawiki/services/parsoid

WORKDIR /usr/lib/parsoid

COPY config.yaml /usr/lib/parsoid

RUN rm config.example.yaml && npm install

COPY docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "apache2-foreground" ]
