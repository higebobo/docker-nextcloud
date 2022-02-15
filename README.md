# docker-nextcloud

Docker for NextCloud (including OnlyOffice and Full Text Search by ElasticSearch)

## Prepare

Emvironment Variables

```shell
cp .env.sample .env
vi .env
```

* `WEB_PORT`: WEB port
* `MYSQL_USER`: User for MariaDB
* `MYSQL_PASSWORD`: Password for MariaDB
* `MYSQL_DATABASE`: Database name for MariaDB
* `INDEX_NAME`: Index name for Elasticsearch

## Setup

```shell
make up
```

### Nextcloud

Access web server (ex http://localhost:8080) and set up

1. Create an admin account
2. Settings for Storage & database
    * Data folder: `/var/www/html/data`
    * Configure the database: `MySQL/MariaDB`
        * Username: `${MYSQL_USER}`
        * Password: `${MYSQL_PASSWORD}`
        * Database: `${MYSQL_DATABASE}`
        * `db`: (**IMPORTANT**) Host must be the docker service name not localhost
3. Set up OnlyOffice
    ```shell
    make onlyoffice
    ```
4. Set up FullText Search
    * `Dashboard`>`Application`>search `Full text search`
    * Install
        * `Full text search`
        * `Full text search - Elasticsearch Platform`
        * `Full text search - Files`
    * `Dashboard`>`Settings`>`Full text search`
        * Search platform: `Elasticsearch`
        * Servlet address: http://elasticsearch:9200/
        * Index: `${INDEX_NAME}`
        * Analizer Tokenizer: `kuromoji_tokenizer`
    * Create and build index
    ```shell
    make index
    ```

## Test

```shell
make test
make test-search
make test-db-info
make test-db
make test-user
make mysql
```

## Link

* [ONLYOFFICE/docker\-onlyoffice\-nextcloud](https://github.com/ONLYOFFICE/docker-onlyoffice-nextcloud)
