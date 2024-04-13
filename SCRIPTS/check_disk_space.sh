#!/bin/bash
threshold=90
usage=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
if [ "$usage" -gt "$threshold" ]; then
  echo "Disk space is low: ${usage}% used."
else
  echo "Disk space check passed."
fi

