#!/bin/bash

address=localhost:9200
archive_name="elastic-"
repo_backup="logbackup"
current_date=$(date +%Y-%m-%d)

echo "backingup current indices"
curl -XPUT -s http://$address/_snapshot/repo_backup/$current_date?wait_for_completion=true -d '{ "ignore_unavailable": true "include_global_state": false }'

echo "backup complete."

