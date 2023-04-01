#!/usr/bin/env bash
set -ueo pipefail

export_statements=$(make-export-statements-from-json-object "$1")

eval "$export_statements"

shift

exec "${@}"
