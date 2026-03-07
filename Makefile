build:
	docker-compose build

debug:
	docker-compose -f docker-compose.yml -f docker/docker-compose.pgadmin.yml up

port-forward:
	ngrok http 8000 --url https://goldfish-able-viper.ngrok-free.app
