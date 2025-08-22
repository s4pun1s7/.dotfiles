#!/usr/bin/env bash
acpi | awk '{ printf("%s: %s %s", $1, $4, $3) }'
