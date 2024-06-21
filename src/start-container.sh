#!/bin/bash

set -e

if [ $# -gt 0 ]; then
	export IS_SERVING=false
else
	export IS_SERVING=true
fi

for f in /docker-entrypoint-init.d/*.sh; do

	if [[ $APP_DEBUG == true ]]; then
		echo "runing $f"
	fi

	/bin/bash $f
done

if [[ $IS_SERVING ]]; then
	"$@"
fi
