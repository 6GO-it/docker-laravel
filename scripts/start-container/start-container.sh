#!/usr/bin/env bash
docker stop $1
docker rm -f $1
docker run \
	--name $1 \
	-d \
    -e WEB_DOCUMENT_ROOT=/app/public \
	-v "$(pdw):/app" \
	-p 80:80 \
	$2
