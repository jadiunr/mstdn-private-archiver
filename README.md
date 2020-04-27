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

## Environment

#### MPA_DOMAIN_NAME
- Mastodon domain name

#### MPA_ACCESS_TOKEN
- Mastodon access token

#### MPA_ACCOUNT_ID
- Mastodon account ID
    - If you are an administrator, ID is 1