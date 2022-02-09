#!/bin/bash

echo; echo "Нажмите клавишу и затем Enter."
read -r Keypress
if [ ${#Keypress} = 1 ]
then
case "$Keypress" in
  [a-z]   ) echo "буква в нижнем регистре";;
  [A-Z]   ) echo "Буква в верхнем регистре";;
  [0-9]   ) echo "Цифра";;
  *       ) echo "Знак пунктуации, пробел или что-то другое";;
esac
else
  echo "Вы нажали больше одной клавиши"
fi
exit 0