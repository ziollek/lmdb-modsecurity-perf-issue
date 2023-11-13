#!/bin/bash

for i in `seq ${1}`;
do
  curl -H"x-set-sample: ${i}" -o /dev/null -s localhost:${2} &
  if [ $(($i % 100)) == "0" ]; then
    wait
    echo "${i} completed"
  fi
done