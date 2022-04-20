#!/bin/bash

echo; echo "Press the key and then Enter."
read -r Keypress
if [ ${#Keypress} = 1 ]
then
case "$Keypress" in
  [a-z]   ) echo "Lower case letter";;
  [A-Z]   ) echo "Upper case letter";;
  [0-9]   ) echo "Digit";;
  *       ) echo "Punctuation, space, or something else";;
esac
else
  echo "You pressed more than one key"
fi
exit 0