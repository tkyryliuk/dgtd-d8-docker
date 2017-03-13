# Read project name from .env file
$(shell cp -n \.env.default \.env)
$(shell cp -n \.\/src\/docker\/docker-compose\.override\.yml\.default \.\/src\/docker\/docker-compose\.override\.yml)
include .env

all: | include net build install info

include:
ifeq ($(strip $(COMPOSE_PROJECT_NAME)),projectname)
$(error Project name can not be default, please edit ".env" and set COMPOSE_PROJECT_NAME variable.)
endif

build:
	make -s clean
	cp -r src/composer build
	mkdir -p /dev/shm/${COMPOSE_PROJECT_NAME}_mysql

install:
	@echo "Updating containers..."
	docker-compose pull
	@echo "Build and run containers..."
	docker-compose up -d
	make -s reinstall

reinstall:
	docker-compose exec php apk add --no-cache git; \
	docker-compose exec php sh -c "cd ../ && composer install --prefer-dist --optimize-autoloader"; \
	make -s si;

si:
	docker-compose exec php sh -c "cd /var/www/web && pwd && drush si --db-url=mysql://d8:d8@mysql/d8 --account-pass=admin -y --site-name=${SITE_NAME} --locale=${SITE_LOCALE}"; \
	make -s chown; \
	make -s info;

info:
ifeq ($(shell docker inspect --format="{{ .State.Running }}" $(COMPOSE_PROJECT_NAME)_web 2> /dev/null),true)
	@echo Project IP: $(shell docker inspect --format='{{.NetworkSettings.Networks.$(COMPOSE_PROJECT_NAME)_front.IPAddress}}' $(COMPOSE_PROJECT_NAME)_web)
endif
ifeq ($(shell docker inspect --format="{{ .State.Running }}" $(COMPOSE_PROJECT_NAME)_mail 2> /dev/null),true)
	@echo Mailhog IP:PORT: $(shell docker inspect --format='{{.NetworkSettings.Networks.$(COMPOSE_PROJECT_NAME)_front.IPAddress}}' $(COMPOSE_PROJECT_NAME)_mail):8025
endif
ifeq ($(shell docker inspect --format="{{ .State.Running }}" $(COMPOSE_PROJECT_NAME)_adminer 2> /dev/null),true)
	@echo Adminer IP: $(shell docker inspect --format='{{.NetworkSettings.Networks.$(COMPOSE_PROJECT_NAME)_front.IPAddress}}' $(COMPOSE_PROJECT_NAME)_adminer)
endif

chown:
# Use this goal to set permissions in docker container
	docker-compose exec php /bin/sh -c "chown $(shell id -u):$(shell id -g) /var/www/web -R"
# Need this to fix files folder
	docker-compose exec php /bin/sh -c "chown www-data: /var/www/web/sites/default/files -R"

exec:
	docker exec -i -t $(COMPOSE_PROJECT_NAME)_php sh -c "cd /var/www/web/ && sh"

clean: info
	@echo "Removing networks for $(COMPOSE_PROJECT_NAME)"
ifeq ($(shell docker inspect --format="{{ .State.Running }}" $(COMPOSE_PROJECT_NAME)_php 2> /dev/null),true)
	docker-compose down; \
	sudo rm -rf build
endif

net:
ifeq ($(strip $(shell docker network ls | grep $(COMPOSE_PROJECT_NAME))),)
	docker network create $(COMPOSE_PROJECT_NAME)_front
endif
	@make -s iprange

iprange:
	$(shell grep -q -F 'IPRANGE=' .env || echo "\nIPRANGE=$(shell docker network inspect $(COMPOSE_PROJECT_NAME)_front --format '{{(index .IPAM.Config 0).Subnet}}')" >> .env)
