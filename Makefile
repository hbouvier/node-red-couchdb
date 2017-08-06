DOCKER_IP:=192.168.99.100

all: build run

build:
	docker build -t hbouvier/node-red-docker:0.17.5-slim .


couchdb:
	docker run -t -d --name couchdb -p 5984:5984 hbouvier/couchdb

run:
	-docker rm node-red
	docker run -it -p 1880:1880 -e NODE_RED_STORAGE_COUCHDB_URL=http://${DOCKER_IP}:5984 --name node-red hbouvier/node-red-docker:0.17.5-slim

open:
	open http://${DOCKER_IP}:1880