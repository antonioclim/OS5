#!/bin/bash
find ~/logs -type f -mtime +30 -name '*.log' -exec rm -f {} \;
echo "Old logs cleaned."

