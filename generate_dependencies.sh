#!/bin/bash


if [ -e /tmp/slurm-dependencies ]; then
    rm /tmp/slurm-dependencies
fi

for component in bin lib lib/slurm sbin
do
    path=/tmp/slurm-build/${component}
    objdump -p $path/* | grep NEEDED | tr -s ' ' | cut -d ' ' -f3 | sort | uniq >> /tmp/slurm-dependencies
done

cat /tmp/slurm-dependencies | sort | uniq > /tmp/slurm-libraries
cat /tmp/slurm-libraries | xargs -n1 dpkg -S | cut -d ' ' -f 1 | sort | uniq | tr ':' ' ' | cut -d ' ' -f 1 > /tmp/slurm-packages
