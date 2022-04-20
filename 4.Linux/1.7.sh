#!/bin/bash
echo "Enter the number of meters"
read -r STR
miles=$(( STR / 1609 ))
echo "$miles"