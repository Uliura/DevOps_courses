#!/bin/bash

RANDOM=$$

PIPS=6
MAXTHROWS=700
throw=0


ones=0
twos=0
threes=0
fours=0
fives=0
sixes=0

print_result ()
{
echo
echo "ones   =   $ones"
echo "twos    =   $twos"
echo "threes    =   $threes"
echo "fours =   $fours"
echo "fives  =   $fives"
echo "sixes =   $sixes"
echo
}

update_count()
{
case "$1" in
  0) (( "ones += 1" ));;
  1) (( "twos += 1" ));;
  2) (( "threes += 1" ));;
  3) (( "fours += 1" ));;
  4) (( "fives += 1" ));;
  5) (( "sixes += 1" ));;
esac
}

echo

while [ "$throw" -lt "$MAXTHROWS" ]
do
  let "die1 = RANDOM % $PIPS" 
  update_count $die1
  (( "throw += 1" ))
done

print_result
exit 0
