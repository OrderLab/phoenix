#!/bin/bash

module is-loaded redis || ( echo "No redis module loaded!"; exit 1 )

redis-cli zinterstore baz 9223372036854775807 graph:node:child graph:node
