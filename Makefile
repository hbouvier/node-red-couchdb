export couchdb_namespace=default
export couchdb_cookie=$(shell uuidgen | tr '[:upper:]' '[:lower:]' | tr -cd '[:print:]')
export couchdb_secret=$(shell uuidgen | tr '[:upper:]' '[:lower:]' | tr -cd '[:print:]')
export couchdb_log_level=info
export couchdb_replicas=1
export couchdb_requests_cpu=250m
export couchdb_requests_memory=512Mi
export couchdb_limits_cpu=250m
export couchdb_limits_memory=512Mi



DOCKER_IP:=192.168.99.100

all: dependencies manifests
clean:
	@rm -f manifest/configmap.yaml manifest/kubernetes-template-configmap.yaml manifest/statefulset.yaml

build:
	docker build -t hbouvier/node-red-docker:0.17.5-slim .


couchdb:
	docker run -t -d --name couchdb -p 5984:5984 hbouvier/couchdb

run:
	-docker rm node-red
	docker run -it -p 1880:1880 -e NODE_RED_STORAGE_COUCHDB_URL=http://${DOCKER_IP}:5984 --name node-red hbouvier/node-red-docker:0.17.5-slim

open:
	open http://${DOCKER_IP}:1880


dependencies: /usr/local/bin/envsubst

/usr/local/bin/envsubst:
	brew install gettext
	brew link --force gettext

manifests: manifest/configmap.yaml manifest/kubernetes-template-configmap.yaml manifest/statefulset.yaml

manifest/configmap.yaml: manifest/templates/configmap.yaml.tpl
	cat manifest/templates/configmap.yaml.tpl | envsubst > manifest/configmap.yaml

manifest/kubernetes-template-configmap.yaml: manifest/templates/kubernetes-template-configmap.yaml.tpl
	cat manifest/templates/kubernetes-template-configmap.yaml.tpl | envsubst > manifest/kubernetes-template-configmap.yaml

manifest/statefulset.yaml: manifest/templates/statefulset.yaml.tpl
	cat manifest/templates/statefulset.yaml.tpl | envsubst > manifest/statefulset.yaml


start:
	kubectl apply -f manifest/
