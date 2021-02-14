# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: btammara <btammara@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/02/13 18:08:16 by btammara          #+#    #+#              #
#    Updated: 2021/02/14 15:29:05 by btammara         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# CONTAINER OS
FROM debian:buster

# UPDATE & UPGARDE PACKAGES
RUN apt-get update
RUN apt-get upgrade -y

# INSTALL WGET AND VIM
RUN apt-get -y install wget
RUN apt-get -y install vim

# INSTALL NGINX, MARIADB, PHP
RUN apt-get -y install nginx
COPY ./srcs/nginx.conf /etc/nginx/sites-available/localhost
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/localhost
COPY ./srcs/index.html /var/www/html/
RUN apt-get -y install mariadb-server
RUN apt-get -y install php7.3-fpm php7.3-common php7.3-mysql php7.3-gmp php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-gd php7.3-xml php7.3-cli php7.3-zip php7.3-soap php7.3-imap

# INSTALL PHP MY ADMIN
WORKDIR /var/www/html/
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0-rc2/phpMyAdmin-5.1.0-rc2-english.tar.gz
RUN tar -xf phpMyAdmin-5.1.0-rc2-english.tar.gz && rm -rf phpMyAdmin-5.1.0-rc2-english.tar.gz
RUN mv phpMyAdmin-5.1.0-rc2-english phpmyadmin
COPY ./srcs/config.inc.php phpmyadmin

# INSTALL WORDPRESS
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz && rm -rf latest.tar.gz
COPY ./srcs/wp-config.php /var/www/html

# COPY PRELOADED DATABASE AND START.SH
COPY ./srcs/wordpress.sql /var/www/html
COPY ./srcs/start.sh /var/

# ISSUE SELFSIGNED SSL CERTIFICATE
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=RU/ST=Republic of Tatarstan/L=Kazan/O=21school/CN=www.localhost' -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt

# START SERVER
CMD bash /var/start.sh

# CREATE NEW FOLDER FOR CHECKING AUTOINDEX
RUN mkdir ai

EXPOSE 80 443