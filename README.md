# logrep-switcher

Testbed for experimenting with logical replication. 

```
cd docker-compose
docker-compose up
```

Will create a source and dest database and setup logical replication between then. Additionally, a pgbouncer will be started
to facilitate switching traffic from source to dest in a controller fashion.

## Do a switchover

```shell
docker exec -it docker-compose_pgbouncer_1 sh

cp /etc/pgbouncer/pgbouncer.ini /etc/pgbouncer/source.pgbouncer.ini
sed -e 's/logrep = host=source port=5433 user=logrep$/logrep = host=dest port=5434 user=logrep/g' /etc/pgbouncer/pgbouncer.ini > /etc/pgbouncer/dest.pgbouncer.ini

cp /etc/pgbouncer/dest.pgbouncer.ini /etc/pgbouncer/pgbouncer.ini
psql -h localhost -p 5432 pgbouncer logrep -c "kill logrep;" && \
  # ideally, wait for 0 lag (show in monitor, see below)
  psql -h localhost -p 5432 pgbouncer logrep -c "reload;" && \
  psql -h localhost -p 5432 pgbouncer logrep -c "set server_login_retry=1;" && \
  psql -h localhost -p 5432 pgbouncer logrep -c "resume logrep;"
  

```


## Useful commands

### Cleanup docker-compose and old volumes

```
docker compose stop; docker compose rm -f ; docker volume prune -f
```

### Setup a monitoring-thread

```
# Setup monitoring of pgbouncer target
docker exec -it docker-compose_pgbouncer_1 sh
while true; do \
  date; \
  clear; \
  psql -h localhost -p 5432 pgbouncer logrep -c "show servers"; \
  psql -h localhost -p 5432 pgbouncer logrep -c "show clients"; \
  psql -h localhost -p 5432 logrep logrep -c "SELECT (select (pg_current_wal_lsn() - confirmed_flush_lsn) AS lsn_distance FROM pg_replication_slots), (select inet_server_addr()), (select inet_server_port( ))"; \
  sleep 1; \
done
```

### PgBouncer commands

```
show servers
show clients
pause
reload
resume
...
```

## Findings

* For pooling-mode=session `PAUSE` will not return until all ongoing sessions are disconnected
    - which means it will not really work, it only makes sense for pooling-mode=transaction
* For `KILL`, tune pgbouncer setting `server_login_retry` for quicker reconnect after `RESUME` is called. 
  - For example `set server_login_retry=1;`)
* `RELOAD` does nothing with established connections
* `KILL` will terminate existing client and server connections. Reconnects will wait until `RESUME` is called 


## Links

* https://github.com/grayhemp/pgcookbook/blob/master/switching_to_another_server_with_pgbouncer.md
