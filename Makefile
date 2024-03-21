APP_ENV := development
DB_NAME := challenge_be_sequra_$(APP_ENV)
DB_USER := postgres

db-connect:
	@docker compose exec db psql -U $(DB_USER) -d $(DB_NAME)

db-create:
	@docker compose exec app rails db:create

db-generate-migration:
	@docker compose exec app rails g migration $(NAME)

db-migrate:
	@docker compose exec app rails db:migrate RAILS_ENV=$(APP_ENV)

db-rollback:
	@docker compose exec app rails db:rollback RAILS_ENV=$(APP_ENV) STEP=$(STEPS)

start:
	@docker compose up --build -d $(SERVICES)

stop:
	@docker compose stop

restart:
	make stop
	make start

destroy:
	@docker compose down

install:
	@docker compose exec app bundle install

console:
	@docker compose exec app rails console

logs:
	@docker compose logs $(SERVICE) -f

lint:
	@docker compose exec app rubocop
