APP_ENV := development
DB_NAME := challenge_be_sequra_$(APP_ENV)
DB_USER := postgres
TEST_PATH := spec
STEPS := 1

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

db-reset:
	@docker compose exec app rails db:reset RAILS_ENV=$(APP_ENV)

db-generate-dump:
	@docker compose exec db pg_dump -U $(DB_USER) $(DB_NAME) > db/dump.sql
	@echo "DB dump generated"

db-restore:
	for table in $$(docker compose exec -T db psql -U $(DB_USER) -d $(DB_NAME) -Atc "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"); do \
		docker compose exec -T db psql -U $(DB_USER) -d $(DB_NAME) -c "ALTER TABLE $$table DISABLE TRIGGER ALL;"; \
	done

	docker compose exec -T db psql -U $(DB_USER) -d $(DB_NAME) < db/dump.sql

	for table in $$(docker compose exec -T db psql -U $(DB_USER) -d $(DB_NAME) -Atc "SELECT tablename FROM pg_tables WHERE schemaname = 'public';"); do \
		docker compose exec -T db psql -U $(DB_USER) -d $(DB_NAME) -c "ALTER TABLE $$table ENABLE TRIGGER ALL;"; \
	done

	@echo "DB restored"

db-import-data:
	@docker compose exec app rake payments_context:merchants:import_data\[db/data/merchants.csv\]
	@docker compose exec app rake payments_context:orders:import_data\[db/data/orders.csv\]

db-disbursements-backfill:
	@docker compose exec app rake payments_context:disbursements:backfill

db-disbursements-generate:
	@docker compose exec app rake payments_context:disbursements:generate

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

test:
	@docker compose exec app rspec ${TEST_PATH}

test-unit:
	@docker compose exec app rspec --tag ~type:database

test-database:
	@docker compose exec app rspec --tag type:database

tasks:
	@docker compose exec app rake -vT

# Do not run from integrated terminal in VSCodium
# control + p, control + q for ending the debugging session
debug:
	@docker attach $$(docker compose ps -q ${SERVICE})

update-cron:
	@docker compose exec app whenever --update-crontab --set environment=${APP_ENV}

check-cron:
	@docker compose exec app crontab -l

clear-cron:
	@docker compose exec app whenever --clear-crontab --set environment=${APP_ENV}

generate-yearly-report:
	@docker compose exec app rake payments_context:generate_yearly_report
