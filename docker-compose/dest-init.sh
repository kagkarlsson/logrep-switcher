#!/bin/bash
set -e


psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE TABLE test(id BIGSERIAL, value int, PRIMARY KEY (id));
	SELECT pg_sleep(5);
	CREATE SUBSCRIPTION my_subscription
  CONNECTION 'host=source port=5433 dbname=logrep user=logrep password=ia6JooHu5c' PUBLICATION my_publication;
EOSQL
