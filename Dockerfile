# FROM dunglas/frankenphp:latest-php8.3-alpine

# RUN apk add --no-cache bash git linux-headers libzip-dev libxml2-dev supervisor nodejs npm chromium

# ENV SERVER_NAME=:80

# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# RUN docker-php-ext-install pdo pdo_mysql sockets pcntl zip exif bcmath

# # Redis
# # RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} \
# #       && pecl install redis \
# #       && docker-php-ext-enable redis \
# #       && apk del pcre-dev ${PHPIZE_DEPS} \
# #       && rm -rf /tmp/pear

# COPY . /app
# WORKDIR /app

# ENV COMPOSER_ALLOW_SUPERUSER=1
# RUN composer install --no-dev --prefer-dist --no-interaction

# RUN npm install
# RUN npm run build


# RUN mkdir /tmp/public/
# RUN cp -r /app/public/* /tmp/public/

# RUN composer require laravel/octane
# RUN yes | php artisan octane:install --server=frankenphp
# RUN /usr/bin/crontab /app/docker/crontab

# # ENV CHROME_PATH=/usr/bin/chromium
# ENV OCTANE_SERVER=frankenphp

# CMD ["php", "artisan", "octane:start", "--server=frankenphp", "--port=80", "--admin-port=81"]
# # ENTRYPOINT ["sh", "/app/docker/entrypoint.sh"]

      
# Étape 1: Build Composer (PHP dependencies)
FROM dunglas/frankenphp:latest-php8.3-alpine AS composer

# Installation des dépendances nécessaires pour Composer
RUN apk add --no-cache bash git linux-headers libzip-dev libxml2-dev supervisor nodejs npm chromium \
    && docker-php-ext-install pdo pdo_mysql sockets pcntl zip exif bcmath


WORKDIR /app

# Installer Composer avec la version spécifique
ENV COMPOSER_VERSION=2.7.0
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=$COMPOSER_VERSION

COPY . /app
# Copier uniquement les fichiers nécessaires pour Composer
# COPY composer.json composer.lock /app/

# Définir le répertoire de travail




# Installer les dépendances PHP
RUN composer install --no-dev --prefer-dist --no-interaction

# Étape 2: Build Node.js (npm dependencies)
FROM node:20-alpine AS npm

# Définir la version de Node.js
ENV NODE_VERSION=20.11.1

COPY . /app
# Copier uniquement les fichiers package.json et package-lock.json
# COPY package.json package-lock.json /app/

WORKDIR /app

# Installer les dépendances Node.js avec npm ci
RUN npm ci

# Build des assets front-end
RUN npm run build



# Étape 3: Final (Production Image)
FROM dunglas/frankenphp:latest-php8.3-alpine AS final

# Installation des packages nécessaires
# RUN apk add --no-cache linux-headers supervisor chromium

RUN apk add --no-cache bash git linux-headers libzip-dev libxml2-dev supervisor chromium \
    && docker-php-ext-install pdo pdo_mysql sockets pcntl zip exif bcmath

# Copier les fichiers de l'étape Composer et npm
COPY --from=composer /app /app
COPY --from=npm /app /app

WORKDIR /app

# Copier les fichiers du projet
COPY . /app

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer



# Préparer les fichiers statiques
RUN mkdir /tmp/public/ \
    && cp -r /app/public/* /tmp/public/

    # Installer Octane et configurer le crontab
RUN composer require laravel/octane \
&& yes | php artisan octane:install --server=frankenphp

RUN /usr/bin/crontab /app/docker/crontab
# Définir les variables d'environnement
ENV SERVER_NAME=:80
ENV OCTANE_SERVER=frankenphp

# Commande pour démarrer Octane avec FrankenPHP
# CMD ["php", "artisan", "octane:start", "--server=frankenphp", "--port=80", "--admin-port=81"]

ENTRYPOINT ["sh", "/app/docker/entrypoint.sh"]