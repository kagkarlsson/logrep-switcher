#!/bin/bash
set -e


psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE TABLE test(id BIGSERIAL, value int, PRIMARY KEY (id));
  INSERT INTO test (value) SELECT generate_series(1,2000);
  CREATE PUBLICATION my_publication FOR ALL TABLES;
EOSQL
