#!/bin/bash

module is-loaded redis || ( echo "No redis module loaded!"; exit 1 )

# Reverting only changes in ticket 10070 will not cause segfault with "GET|"
# input, because a later fix has added other fix logic.
# https://github.com/redis/redis/commit/a6fd2a46d101d4df23ade2e28cbc04656c721b2b#diff-1abc5651133d108c0c420d9411925373c711133e7748d9e4f4c97d5fb543fdd9R2827-R2828

# Good news is, command with valid subcommand will also result in segfault. The
# root cause for this bug is the wrong argc in processCommand vs the correct
# argc in lookupCommandLogic.
redis-cli "CLIENT|LIST"

# Reproducible also on 75c50a15633881bb2bf0455bdabcbbabc0e47044 (parent of a84c964d37a1899bf90c920efef85a1d7202d058).
