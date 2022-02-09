#!/bin/bash
if [ "$UID" -eq 0 ]
then
   echo "not root"
   exit 1
else
  echo "root"
  exit 1
fi