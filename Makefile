.PHONY: all init credential up up-d down exec bash docker docker-rm

# CONST

# VARIABLE
a=

all: exec


init:
	cp .env.dev.sample .env.dev
	docker volume create --name=app_sync_volume
	docker-sync start
	docker-compose build
	docker-compose run --rm app bundle exec rails new . --force --database=mysql --skip-turbolinks --skip-git --skip-test
	cp -f template/database.yml config/database.yml
	docker-compose run --rm app bundle exec spring binstub --all
	docker-compose run --rm app wget https://raw.githubusercontent.com/svenfuchs/rails-i18n/master/rails/locale/ja.yml --output-file=config/locales/ja.yml
	echo gem \'slim-rails\'"\n"gem \'html2slim\'"\n"gem \'bootstrap\' >> Gemfile
	docker-compose run --rm app bundle install
	docker-compose run --rm app bundle exec erb2slim app/views/layouts/ --delete
	docker-compose run --rm app bin/rails db:create
	docker-compose run --rm app bin/rails db:migrate
	docker-sync stop


credential:
	docker-compose run --rm app bin/rails credentials:edit

up:
	docker-sync start
	docker-compose up

up-d:
	docker-sync start
	docker-compose up -d

down:
	docker-sync stop
	docker-compose down

exec:
	docker-compose exec app ${a}

bash:
	docker-compose exec app bash

###########################################################################################################
docker:
	docker system df -v

docker-rm:
	docker system prune -a --volumes
