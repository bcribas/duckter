#!/bin/bash

source gerador-functions.sh

addchaves 1000 A 20
gentags 2000 A
taghit 3000
buscatags 40
echo list trending top 15
addchaves 2000 B 20
gentags 4000 B
taghit 6000
echo list trending top 15
echo dump keys
echo dump tags
echo list trending bottom 40
