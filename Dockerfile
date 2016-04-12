FROM php:7.0-apache
MAINTAINER Pierre Klink <dev@klink.xyz>

ENV MYSQL_HOST mysql
ENV MYSQL_USERNAME root
ENV MYSQL_PASSWORD password
ENV MYSQL_DATABASE machdas

COPY ./ /var/www/

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - \
    && apt-get install -y nodejs build-essential git unzip zlib1g-dev \
    && docker-php-ext-install zip mbstring pdo pdo_mysql \
    && php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php \
    && php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === '7228c001f88bee97506740ef0888240bd8a760b046ee16db8f4095c0d8d525f2367663f22a46b48d072c816e7fe19959') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

WORKDIR /var/www
RUN composer install --no-dev \
    && npm install \
    && npm run build \
    && rm -rf node_modules/ html/ \
    && mv public/ html

RUN cp config.sample.php config.php \
    && sed -i "s/127.0.0.1/$MYSQL_HOST/g" config.php \
    && sed -i "s/root/$MYSQL_USERNAME/g" config.php \
    && sed -i "s/secret/$MYSQL_PASSWORD/g" config.php \
    && sed -i "s/machdas/$MYSQL_DATABASE/g" config.php

RUN apt-get remove -y nodejs build-essential git unzip \
    && apt-get clean

EXPOSE 80
