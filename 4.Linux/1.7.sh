#!/bin/bash
echo "Введите количество метров"
read -r STR
miles=$(( STR / 1609 ))
echo "$miles"