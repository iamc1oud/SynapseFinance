build:
	docker-compose build

debug:
	docker-compose -f docker-compose.yml -f docker/docker-compose.pgadmin.yml up
