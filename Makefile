build:
	docker-compose build

run:
	docker-compose up

test:
	docker-compose run --rm web pytest

lint:
	docker-compose run --rm web pylint --rcfile=.pylintrc synapse

format:
	docker-compose run --rm web black synapse
