kind: ConfigMap
apiVersion: v1
metadata:
  name: couchdb-kubernetes-ini-template
  annotations:
    konfd.io/kind: configmap
    konfd.io/name: couchdb-kubernetes
    konfd.io/key:  kubernetes.ini
  labels:
    konfd.io/template: "true"
    app: node-red
    component: couchdb
data:
  # CouchDB server setttings. The UUID is employed in replication checkpoints
  # and should be for unique for each cluster, but shared by all members of a
  # cluster.    
  template: |
    # Each Couchdb Cluster MUST have a unique uuid per Cluster
    [couchdb]
    uuid = couchdb-${couchdb_namespace}

    # Admin user is configured using the Bootstrap Companion app
    [admins]
    {{ secret "couchdb" "username" }} = {{ secret "couchdb" "password" }}

    [log]
    level = ${couchdb_log_level}

    [couch_httpd_auth]
    require_valid_user = true
    secret = ${couchdb_secret}
    timeout = 3600
    
    [httpd]
    # [default.ini] socket_options = [{recbuf, 262144}, {sndbuf, 262144}, {nodelay, true}]
    socket_options = [{recbuf, 262144}, {sndbuf, 262144}, {nodelay, true}, {keepalive,true}]
    # [default.ini] server_options = [{backlog, 128}, {acceptor_pool_size, 16}]
    # server_options = [{backlog, 8192}, {acceptor_pool_size, 4096}]
    allow_jsonp = false
    enable_cors = false

    [replicator]
    ; worker_batch_size = 1000
    worker_batch_size = 4096
    max_replication_retry_count = infinity

    [cluster]
    # q=8   ; Shards
    # n=3   ; Replicas: The number of copies there is of every document. (n=1 all node up,n=2 any one node down,...)
    # r=2   ; The number of copies of a document with the same revision that have to be read before CouchDB returns with a 200 and the document
    # w=2   ; The number of nodes that need to save a document before a write is returned with 201.
    # # curl http://localhost:5986/nodes -d '{"zone":"us-east-1"}'
    # # placement = us-east-1:2,us-west-1:1
    q=8
    n=1
    r=1
    w=1

    [chttpd]
    bind_address = any
    # [default.ini] backlog = 512
    backlog = 8192
    # [default.ini] socket_options = [{recbuf, 262144}, {sndbuf, 262144}, {nodelay, true}]
    socket_options = [{recbuf, 262144}, {sndbuf, 262144}, {nodelay, true}, {keepalive,true}]

    require_valid_user = true
