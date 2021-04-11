#!/usr/bin/env bash

echo "Pre-deploy hook starting."

# Jump into drupal path.
cd ~/public_html/docroot/sites/

drush -Dssh.tty=0 sset system.maintenance_mode 1
drush -Dssh.tty=0 sql-dump > ~/private_html/backups/db_$(date +"%Y-%m-%d-%H-%M-%S").sql
