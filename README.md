

## Create admin account

```
docker-compose exec web bash
cd current && RAILS_ENV=production bundle exec rake admin:create
```
