#!/usr/bin/env bash

mix deps.get
mix ecto.reset
cd assets/ && npm install
mix compile
MIX_ENV=test mix compile
