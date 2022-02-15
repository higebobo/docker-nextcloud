MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := up

# all targets are phony
.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

WEB_PORT=8080
#SSL_PORT=443
SEARCH_PORT=9200
#SEARCH_NODE_PORT=9300
#MONITOR_PORT=5601
MYSQL_ROOT_PASSWORD=secret
#MYSQL_PORT=3306
MYSQL_USER=nextcloud
MYSQL_PASSWORD=secret
MYSQL_DATABASE=nextcloud
INDEX_NAME=nextcloud

# .env
ifneq ("$(wildcard ./.env)","")
  include ./.env
endif

export WEB_PORT
#export SSL_PORT
export SEARCH_PORT
#export SEARCH_NODE_PORT
#export MONITOR_PORT
export MYSQL_ROOT_PASSWORD
#export MYSQL_PORT
export MYSQL_USER
export MYSQL_PASSWORD
export MYSQL_DATABASE

export WEB_CONTAINER=nginx-server
export APP_CONTAINER=app-server
export DOC_CONTAINER=onlyoffice-document-server
export SEARCH_CONTAINER=elasticsearch-server
#export MONITOR_CONTAINER=kibana-server
export DB_CONTAINER=mariadb-server

up: ## Docker process up
	@docker-compose up -d --build

down: ## Docker process down
	@docker-compose down

restart: ## Docker process restart
	@docker-compose restart

down-all: down ## Docker process down all
	@docker-compose down --rmi all --volumes

clean: ## Docker clean
	@sudo rm -fr ./data/*

onlyoffice: ## Set up Only Office
	@/bin/sh config/set_configuration.sh

index-init: ## Initialize Fulltext search index
	@docker exec -u www-data -it ${APP_CONTAINER} /bin/sh -c 'curl -X PUT http://elasticsearch:${SEARCH_PORT}/${INDEX_NAME}?pretty'

index-test: ## Test Fulltext search index
	@docker exec -u www-data -it ${APP_CONTAINER} /bin/sh -c 'php occ fulltextsearch:test'

index-reset: ## Reset Fulltext search index
	@docker exec -u www-data -it ${APP_CONTAINER} /bin/sh -c 'php occ fulltextsearch:reset'

index: ## Create Fulltext search index
	@docker exec -u www-data -it ${APP_CONTAINER} /bin/sh -c 'php occ fulltextsearch:index'

ps: ## Docker process
	@docker-compose ps

ps-web: ## Docker process for web server
	@docker ps | grep ${WEB_CONTAINER}

ps-app: ## Docker process for application
	@docker ps | grep ${APP_CONTAINER}

ps-doc: ## Docker process for document server
	@docker ps | grep ${DOC_CONTAINER}

ps-search: ## Docker process for search server
	@docker ps | grep ${SEARCH_CONTAINER}

ps-db: ## Docker process for database
	@docker ps | grep ${DB_CONTAINER}

log: ## Docker log
	@docker-compose logs

log-web: ## Docker log for web server
	@docker-compose logs ${WEB_CONTAINER}

log-app: ## Docker log for application server
	@docker-compose logs ${APP_CONTAINER}

log-doc: ## Docker log for document server
	@docker-compose logs ${DOC_CONTAINER}

log-search: ## Docker log for search server
	@docker-compose logs ${SEARCH_CONTAINER}

log-db: ## Docker log for database
	@docker-compose logs ${DB_CONTAINER}

shell: shell-app-www ## Shell

shell-web: ## Shell process for web server
	@docker exec -it ${APP_CONTAINER} /bin/sh

shell-app: ## Shell for application (root)
	@docker exec -it ${APP_CONTAINER} /bin/sh

shell-app-www: ## Shell
	@docker exec -u www-data -it ${APP_CONTAINER} /bin/sh

shell-doc: ## Shell for document server
	@docker exec -it ${DOC_CONTAINER} /bin/sh

shell-search: ## Shell for search server
	@docker exec -it ${SEARCH_CONTAINER} /bin/sh

shell-db: ## Shell process for database
	@docker exec -it ${DB_CONTAINER} /bin/sh

version: version-web ## Show version

version-web:
	@docker exec -it ${WEB_CONTAINER} 'nginx' '-v'

version-app:
	@docker exec -it ${APP_CONTAINER} 'php' '-v'

version-db:
	@docker exec -it ${DB_CONTAINER} 'mysql' '-V'

mysql:
	@docker exec -it ${DB_CONTAINER} /bin/sh -c 'mysql -u root --password=${MYSQL_ROOT_PASSWORD}'

test:
	@curl -LI http://localhost:${WEB_PORT} -o /dev/null -w'%{http_code}\n' -s

test-db-info:
	@docker exec -it ${DB_CONTAINER} /bin/sh -c 'mysql -u root --password=${MYSQL_ROOT_PASSWORD} -e "SHOW VARIABLES LIKE \"chara%\""'

test-user:
	@docker exec -it ${DB_CONTAINER} /bin/sh -c 'mysql -u root --password=${MYSQL_ROOT_PASSWORD} -e "SELECT host, user, select_priv FROM mysql.user"'

test-db:
	@docker exec -it ${DB_CONTAINER} /bin/sh -c 'mysql -u root --password=${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES;"'

test-search:
	@docker exec -u www-data -it ${APP_CONTAINER} /bin/sh -c 'curl -X GET http://elasticsearch:${SEARCH_PORT}/_cat/health'

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
