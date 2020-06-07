#!/usr/bin/env bash
if [[ $# -eq 0 ]] ; then
    echo 'error: a chunk number is required'
    exit 1
fi

elixir --name chunk$1@127.0.0.1 --cookie asdf -S mix run --no-halt
