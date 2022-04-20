#!/bin/bash
echo "Input a string. You have 5 seconds"
read -rt 5 variable <&1
if [ -z "$variable" ]
then
  echo "Time out"
else
  echo "$variable"
fi