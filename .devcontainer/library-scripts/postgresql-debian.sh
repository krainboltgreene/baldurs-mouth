#!/usr/bin/env bash

echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && cat /etc/apt/sources.list.d/pgdg.list \
  && curl --silent https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update \
  && apt-get install --no-install-recommends -y postgresql-client-15
