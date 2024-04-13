#!/bin/bash
top -b -n 1 > ~/performance_$(date +%Y%m%d%H%M%S).log
echo "Performance metrics logged."

