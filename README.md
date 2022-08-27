# logrep-switcher

Testbed for experimenting with logical replication. 

```
cd docker-compose
docker-compose up
```

Will create a source and dest database and setup logical replication between then. Additionally, a pgbouncer will be started
to facilitate switching traffic from source to dest in a controller fashion (WIP).