#!/bin/bash

source gerador-functions.sh

addchaves 1000 A 20
gentags 2000 A
taghit 3000
gentags 1000 B
for((i=5;i<=70;i+=5)); do
  echo "list trending top $i"
  echo "list trending bottom $i"
  taghit 200
done
echo dump keys
echo dump tags
