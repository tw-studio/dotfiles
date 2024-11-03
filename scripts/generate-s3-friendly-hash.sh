#!/bin/bash
#
# generate-s3-friendly-hash.sh

SUFFICIENTLY_RANDOM_LENGTH=25
HASH=$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9-' | fold -w $SUFFICIENTLY_RANDOM_LENGTH | head -n 1)

echo "$HASH"

