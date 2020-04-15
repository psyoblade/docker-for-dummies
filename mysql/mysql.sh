#!/bin/bash
echo "docker run -d --rm --name mysql -e \"MYSQL_ALLOW_EMPTY_PASSWORD=yes\" -v `pwd`/data/mysql:/var/lib/mysql -it mysql"
