#!/bin/bash
base=https://raw.githubusercontent.com/docker/machine/v0.16.2
for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
do
  sudo wget "$base/contrib/completion/bash/${i}" -P /etc/bash_completion.d
done

