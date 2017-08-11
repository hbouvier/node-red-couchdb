kind: ConfigMap
apiVersion: v1
metadata:
  name: couchdb
  labels:
    app: node-red
    component: couchdb
data:
  # Erlang VM settings. The -name flag activates the Erlang distribution; there
  # should be no reason to change this setting. The -setcookie flag is used to
  # control the Erlang magic cookie. CouchDB cluster nodes can only establish a
  # connection with one another if they share the same magic cookie.
  erlflags: >
    -name couchdb
    -setcookie ${couchdb_cookie}
