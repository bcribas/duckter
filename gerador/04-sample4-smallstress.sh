#!/bin/bash

source gerador-functions.sh

addchaves 50 A
gentags 150 A
taghit 100
echo dump keys
buscatags 10
echo list trending top 15
addchaves 50 B
gentags 150 B
taghit 100
echo list trending top 15
echo dump keys
echo dump tags
