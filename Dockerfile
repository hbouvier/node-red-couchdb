FROM nodered/node-red-docker:0.17.5-slim

RUN cd /data && \
    npm install node-red-dashboard \
        node-red-node-cf-cloudant \
        node-red-contrib-amqp \
        node-red-node-sqlite \
        node-red-contrib-chatbot \
        node-red-node-swagger \
        node-red-contrib-elasticsearch \
        node-red-contrib-fs-ops \
        node-red-contrib-circularbuffer \
        json-db-node-red \
        node-red-contrib-viseo-api-ai \
        node-red-contrib-jenkins \
        node-red-contrib-slack \
        node-red-contrib-json2csv \
        node-red-node-redis \
        node-red-contrib-trello \
        node-red-contrib-file-upload \
        node-red-contrib-timecheck \
        node-red-contrib-ftp \
        node-red-contrib-json \
        node-red-contrib-advanced-ping \
        node-red-contrib-docker-stream \
        node-red-contrib-xml-validate \
        nano

# COPY container/ /usr/src/node-red/node_modules/node-red/

COPY container/ /data/

ENV NODE_RED_STORAGE_COUCHDB_URL=http://192.168.99.100:5984 \
    NODE_RED_STORAGE_COUCHDB_DBNAME=node-red