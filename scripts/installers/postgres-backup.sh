#!/bin/bash
# Create Postgres Backup

echo "q-postgres-rw.q-postgres.svc.cluster.local:5432:app:q_postgres:dtcsJUrZXKufKz3" > ~/.pgpass
chmod 600 ~/.pgpass
pg_dump -h q-postgres-rw.q-postgres.svc.cluster.local -U q_postgres stocky > stocky.sql