#!/bin/bash

# Experiment Constants
declare -a LBs=("distributed" "greedy" "nolb" "packdrop" "refine")
declare -a APP="leanmd"

# Output Content
# This script assumes these variables are static...
# They are here presented for better readability, any changes on them must be met with changes to the respectives functions "parse_app_time" and "parse_step_time"
declare -a METRIC_FILES=("apptime" "steptime")
declare -a STEP_METRICS=("step_time")
declare -a APP_METRICS=("app_time")
declare -a COMMON_METRICS=("sched")

# Organization constants
declare -a IN_EXT=".res" # Input file extension
declare -a BASE_DIR="experiments/g5k" # Experiments directory
declare -a RAW_DIR="raw-data" # Raw data subdirectory

#Output constants
declare -a OUT_EXT=".csv" # Output file extension
declare -a PARSE_DIR="parsed-data" # Parsed data subdirectory
declare -a OUTPUT_FILES=() # A list of output files created dynamically by the "init_outfiles" functions

# Prints the header variable into the file while deleting its previous contents
# $1 is the output file
# $2 is the header array contents
function make_csv_header {
  local OUT=$1
  shift
  
  HDR=$(printf ",%s" "${COMMON_METRICS[@]}")
  HDR=${HDR:1}$(printf ",%s" "$@")
  echo $HDR > $OUT
}

# Gather the Application Metrics from the input file
# $1 is the input file
# $2 is the scheduling policy
# $3 is the output file
function parse_app_time {
  awk -v outfile=$3 -v sched=$2 '/Total application time/{print sched","$4 >> outfile; close(outfile)}' $1
}

# Gather the Simulation Step Metrics from the input file
# $1 is the input file
# $2 is the scheduling policy
# $3 is the output file
function parse_step_time {
  awk -v outfile=$3 -v sched=$2 '/Benchmark Time/{print sched","$5 >> outfile; close(outfile)}' $1
}

# Parse the full Charm++ log file
# $1 is the input file
# $2 is the scheduling policy associated with the file
function parse_single {
  make_csv_header $3 ${APP_METRICS[@]}
  make_csv_header $4 ${STEP_METRICS[@]}
  parse_app_time $1 $2 ${OUTPUT_FILES[0]}
  parse_step_time $1 $2 ${OUTPUT_FILES[1]}
}

function init_outfiles {
  local i=0
  for outfile in ${METRIC_FILES[@]}; do
    OUTPUT_FILES[$i]="${BASE_DIR}/${PARSE_DIR}/${APP}_${outfile}${OUT_EXT}"
    ((i++))
  done
}

function create_headers {
  init_outfiles
  make_csv_header ${OUTPUT_FILES[0]} ${APP_METRICS[@]}
  make_csv_header ${OUTPUT_FILES[1]} ${STEP_METRICS[@]}
}

############################# Execution flow ##############################
cd $(dirname "$0")/..
mkdir -p $BASE_DIR/$PARSE_DIR
rm -rf $BASE_DIR/$PARSE_DIR/*

create_headers

for lb in ${LBs[@]}; do
  FILE="${BASE_DIR}/${RAW_DIR}/${APP}_${lb}${IN_EXT}"
  
  parse_single $FILE $lb
done