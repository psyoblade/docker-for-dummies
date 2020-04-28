#!/bin/bash
echo "docker run --rm --name mysql --network=sqoop-mysql -e \"MYSQL_ALLOW_EMPTY_PASSWORD=yes\" -v `pwd`/data/mysql:/var/lib/mysql -dit mysql"
