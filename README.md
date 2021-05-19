Docker image for Discourse
==========================

Existing docker images for Discourse are too complex or simply didn't work.
So I created my own image.
You find my
[Discourse Images on Docker Hub](https://hub.docker.com/repository/docker/digineode/discourse).

## Building a specific version

    make build VERSION=v2.5.0.beta7

## Create admin account

```
docker-compose exec web /app/bundle exec rake admin:create
```
