#!/bin/bash
exitCode=0
for file in `ls **/*.bicep`; do
  az bicep build --file $file --stdout 2>&1 > /dev/null | grep -iE '^warning|^error'
  if [ $? -eq 0 ]; then
    exitCode=1
  fi
done
exit $exitCode
