#!/usr/bin/env bash

curl -fSL -o /tmp/elixir-otp-26.zip https://github.com/elixir-lang/elixir/releases/download/v1.15.3/elixir-otp-26.zip \
  && unzip /tmp/elixir-otp-26.zip -d /usr/src/elixir/ \
  && chown -R $USERNAME:$USERNAME /usr/src/elixir/ \
  && rm /tmp/elixir-otp-26.zip
