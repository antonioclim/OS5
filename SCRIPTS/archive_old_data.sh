#!/bin/bash
find ~/data -type f -mtime +365 -exec gzip {} \;
echo "Old data archived."

