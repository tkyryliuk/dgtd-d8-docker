## Docker based DEV environment for Drupal 8

---

#### Based on [skilld-docker-container](https://github.com/skilld-labs/skilld-docker-container)

* [Overview](#overview)
* [Instructions](#instructions)
* [Usage](#usage)

## Overview

Default Drupal 8 installation with Docker.

Environment info:
  - PHP 7.1
  - Nginx 1.10
  - Percona 5.7

## Instructions

1\. Install docker for <a href="https://docs.docker.com/engine/installation/" target="_blank">Linux</a>, <a href="https://docs.docker.com/engine/installation/mac" target="_blank">Mac OS X</a> or <a href="https://docs.docker.com/engine/installation/windows" target="_blank">Windows</a>. __For Mac and Windows make sure you're installing native docker app version 1.13, not docker toolbox.__

For Linux install <a href="https://docs.docker.com/compose/install/" target="_blank">docker compose</a>

## Usage

* `make` - Install project.
* `make clean` - totally remove project build folder, docker containers and network.
* `make reinstall` - reinstall site.
* `make info` - Show project info (IP).
* `make chown` - Change permissions inside container. Use it in case you can not access files in _build_. folder from your machine.
* `make exec` - docker exec into php container.
* `docker-compose stop` - stop running services
* `docker-compose start` - start services (use  after creating of the project)
