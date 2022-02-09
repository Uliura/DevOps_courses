#!/bin/bash
echo "Введите строку. У вас есть 5 секунд."
read -rt 5 variable <&1
if [ -z "$variable" ]
then
  echo "Время ожидания истекло."
else
  echo "$variable"
fi