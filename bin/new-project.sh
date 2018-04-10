#!/bin/bash

####### Print Help Function ################################
function PRINT_HELP {
  echo -e "This script creates the directory structure needed for the parsers to function properly.\nThe correct usage is as follows:"
  echo -e "  ./$0 'project_name' 'experiment_name' 'experiment_name' ..."
  exit 0
}
############################################################

################# Parse Arguments ##########################
function PARSE_PARAMS {
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
  -h|--help)
  PRINT_HELP
  exit
  ;;
  *)
  break
  ;;
esac
done
}


cd $(dirname "$0")/..
PARSE_PARAMS $@

PROJ_NAME=$1
shift

mkdir -p $PROJ_NAME
mkdir -p $PROJ_NAME/experiments
mkdir -p $PROJ_NAME/results

ln -f -s -r resources/parseutils $PROJ_NAME/experiments/
touch "$PROJ_NAME/experiments/result-parser.py"
echo "Write the remarks about this project in this file for future reference." > $PROJ_NAME/readme.txt

cd $PROJ_NAME/experiments

for experiment in "$@"
do
  mkdir -p $experiment
  mkdir -p $experiment/raw-data
  mkdir -p $experiment/parsed-data
done