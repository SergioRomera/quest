#!/bin/bash
#Description: shred functions

# ******************************************************************************
# Function dwt
# ******************************************************************************
function dwt() { 
  #echo "\033[0;31;40m"$(date "+%Y%m%d-%H%M%S")"\033[0m" 
  d=$(date "+%Y%m%d-%H%M%S")
  printf "\033[0;34;40m$d\033[0m" 
}

# Error message function
error () {
  #printf "\033[0;31;40m[`date +\"%d/%m/%Y %H:%M:%S\"`] ERROR : $@ \033[0m"
  printf "[$(dwt)]\033[0;31;40m $@ \033[0m\n"
  #exit 1
}

info () {
  printf "[$(dwt)]\033[0;32;40m $@ \033[0m\n"
}
