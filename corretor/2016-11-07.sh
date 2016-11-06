#!/bin/bash

cd ../gerador

source gerador-functions.sh

addchaves 500 A 200
gentags 40000 A
taghit 25000
echo list trending top 90
echo dump keys
echo dump tags
