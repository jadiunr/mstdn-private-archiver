# Mastodon Private Archiver

- 自己責任

## Setup

```
cp .env.sample .env
vim .env

docker-compose build
docker-compose run --rm app carton install
docker-compose up -d
```