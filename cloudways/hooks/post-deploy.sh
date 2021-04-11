#!/usr/bin/env bash

echo "Post-deploy hook starting."

# Jump into drupal path.
cd ~/public_html/docroot/sites/

drush -Dssh.tty=0 cr
drush -Dssh.tty=0 updb -y
drush -Dssh.tty=0 cim -y
drush -Dssh.tty=0 cim -y
drush -Dssh.tty=0 sset system.maintenance_mode 0
drush -Dssh.tty=0 cr
