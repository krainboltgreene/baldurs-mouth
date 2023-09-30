#!/usr/bin/env bash

packages='
erlang-base
erlang-asn1
erlang-crypto
erlang-dev
erlang-mnesia
erlang-tftp
erlang-parsetools
erlang-eunit
erlang-odbc
erlang-syntax-tools
erlang-wx
erlang-debugger
erlang-runtime-tools
erlang-snmp
erlang-os-mon
erlang-et
erlang-observer
erlang-megaco
erlang-public-key
erlang-ssh
erlang-ssl
erlang-ftp
erlang-eldap
erlang-diameter
erlang-inets
erlang-xmerl
erlang-edoc
erlang-erl-docgen
erlang-tools
erlang-dialyzer
erlang-reltool
erlang-common-test
'

for package in $packages
do
  echo "Downloading ${package}" \
  && curl -fS -o "/tmp/${package}.deb" "https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/deb/ubuntu/pool/jammy/main/e/er/${package}_1:26.0.2-1/${package}_26.0.2-1_amd64.deb" \
  && echo "Unpacking ${package}" \
  && dpkg -i "/tmp/${package}.deb"
done \
  && echo "Downloading erlang-doc" \
  && curl -fS -o /tmp/erlang-doc.deb https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/deb/ubuntu/pool/jammy/main/e/er/erlang-doc_1:26.0.2-1/erlang-doc_26.0.2-1_all.deb \
  && echo "Unpacking erlang-doc" \
  && dpkg -i /tmp/erlang-doc.deb \
  && echo "Downloading erlang" \
  && curl -fS -o /tmp/erlang.deb https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/deb/ubuntu/pool/jammy/main/e/er/erlang_1:26.0.2-1/erlang_26.0.2-1_all.deb \
  && echo "Unpacking erlang" \
  && dpkg -i /tmp/erlang.deb \
  && rm /tmp/erlang-*
