apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  name: couchdb
spec:
  serviceName: couchdb-discovery
  replicas: ${couchdb_replicas}
  template:
    metadata:
      annotations:
        pod.alpha.kubernetes.io/initialized: "true"
      labels:
        app: node-red
        component: couchdb
    spec:
      restartPolicy: Always
      terminationGracePeriodSeconds: 30
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: component
                  operator: In
                  values:
                  - couchdb
              topologyKey: kubernetes.io/hostname
      containers:
      - name: couchdb
        image: hbouvier/couchdb:2.0.0-20170701
        imagePullPolicy: IfNotPresent
        command: ["/bin/sh", "-c", "if [ ! -r /opt/couchdb/etc/local.d/local.ini ] ; then touch /opt/couchdb/etc/local.d/local.ini ; fi ; /opt/couchdb/bin/couchdb"]
        env:
        - name: ERL_FLAGS
          valueFrom:
            configMapKeyRef:
              name: couchdb
              key: erlflags
        ports:
        - containerPort: 5984
          name: data
        - containerPort: 5986
          name: local
        - containerPort: 4369
          name: erlang-epmd
        - containerPort: 9100
          name: erlang-dist
        resources:
          requests:
            cpu: ${couchdb_requests_cpu}
            memory: ${couchdb_requests_memory}
          limits:
            cpu: ${couchdb_limits_cpu}
            memory: ${couchdb_limits_memory}
        readinessProbe:
          httpGet:
            path: /_up
            port: 3000
          initialDelaySeconds: 15
          periodSeconds: 10
          timeoutSeconds: 1
          successThreshold: 1
          failureThreshold: 20
        livenessProbe:
          httpGet:
            path: /_up
            port: 3000
          initialDelaySeconds: 15
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 5
        volumeMounts:
        - mountPath: /opt/couchdb/data
          name: data-${couchdb_namespace}
        - mountPath: /opt/couchdb/etc/default.d
          name:  defaultd
        - mountPath: /opt/couchdb/etc/local.d
          name:  conf-${couchdb_namespace}
      - name: bootstrap
        image: hbouvier/couchdb-bootstrap-kubernetes:2.0.0-002
        imagePullPolicy: IfNotPresent # IfNotPresent, Always, Never
        env:
        - name: NODE_ENV
          value: production
        # - name: DEBUG
        #   value: "true"
        - name: COUCHDB_USER
          valueFrom:
            secretKeyRef:
              name: couchdb
              key: username
        - name: COUCHDB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: couchdb
              key: password
        resources:
          requests:
            cpu: 75m
            memory: 100Mi
          limits:
            cpu: 75m
            memory: 100Mi
        readinessProbe:
          httpGet:
            path: /healthz
            port: 3000
          initialDelaySeconds: 10
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 5
        livenessProbe:
          httpGet:
            path: /healthz
            port: 3000
          initialDelaySeconds: 15
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 5
      volumes:
      - name: defaultd
        configMap:
          name: couchdb-kubernetes
          items:
            - key: kubernetes.ini
              path: kubernetes.ini
      - name: data-${couchdb_namespace}
        persistentVolumeClaim:
          claimName: data-${couchdb_namespace}
      - name: conf-${couchdb_namespace}
        persistentVolumeClaim:
          claimName: conf-${couchdb_namespace}
  volumeClaimTemplates:
  - metadata:
      name: data-${couchdb_namespace}
    spec:
      # persistentVolumeReclaimPolicy: Retain
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 32Gi
  - metadata:
      name: conf-${couchdb_namespace}
    spec:
      # persistentVolumeReclaimPolicy: Retain
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: 100Mi
