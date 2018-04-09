#!/bin/bash

# Experiment Constants
declare -a LBs=("dist" "greedy" "nolb" "pdlb" "refine")
declare -a APPs=("leanmd" "lbtest")
declare -a LEANMD_PERIODS=("long" "short")
declare -a LBTEST_TOPOS=("mesh2d" "mesh3d" "ring")

# Output Content
# This script assumes these variables are static...
# They are here presented for better readability, any changes on them must be met with changes to the respectives functions "parse_app_time" and "parse_step_time"
declare -a METRIC_FILES=("apptime" "steptime")

declare -a COMMON_METRICS="sched,app"

declare -a STEP_METRICS=",step_time"
declare -a APP_METRICS=",app_time"

declare -a LEANMD_METRICS=",period"
declare -a LBTEST_METRICS=",topo"

# Organization constants
declare -a IN_EXT=".res" # Input file extension
declare -a BASE_DIR="experiments/g5k/" # Experiments directory
declare -a RAW_DIR="raw-data/" # Raw data subdirectory

declare -a LEANMD_DIR="${BASE_DIR}${RAW_DIR}${APPs[0]}/"
declare -a LBTEST_DIR="${BASE_DIR}${RAW_DIR}${APPs[1]}/"

#Output constants
declare -a OUT_EXT=".csv" # Output file extension
declare -a PARSE_DIR="parsed-data/" # Parsed data subdirectory

# Gather the Application Metrics from the input file
# $1 is the input file
# $2 is the scheduling policy
# $3 is the wild metric
# $4 is the executed application
# $5 is the output file
function parse_app_time {
  awk -v outfile=$5 -v sched=$2 -v app=$4 -v wildmetric=$3 '/Total application time/{print sched","app","wildmetric","$4 >> outfile; close(outfile)}' $1
}

# Gather the Application Metrics from the input file
# $1 is the input file
# $2 is the scheduling policy
# $3 is the wild metric
# $4 is the executed application
# $5 is the output file
function parse_lbtest_app_time {
  awk -v outfile=$5 -v sched=$2 -v app=$4 -v wildmetric=$3 '/STEP.150/{print sched","app","wildmetric","$5 >> outfile; close(outfile)}' $1
}


# Gather the Simulation Step Metrics from the input file
# $1 is the input file
# $2 is the scheduling policy
# $3 is the wild metric
# $4 is the executed application
# $5 is the output file
function parse_step_time {
  awk -v outfile=$5 -v sched=$2 -v app=$4 -v wildmetric=$3 '/Benchmark Time/{print sched","app","wildmetric","$5 >> outfile; close(outfile)}' $1
}

function create_headers {
  for metric in ${METRIC_FILES[@]}; do
    for app in ${APPs[@]}; do
      OUTPUT_FILE="${BASE_DIR}${PARSE_DIR}${app}_${metric}${OUT_EXT}"
      
      OUTPUT_FILE_HDR="${COMMON_METRICS}"
      
      if [[ $app = "${APPs[0]}" ]]; then
        OUTPUT_FILE_HDR="${OUTPUT_FILE_HDR}${LEANMD_METRICS}"
      fi
      
      if [[ $app = "${APPs[1]}" ]]; then
        OUTPUT_FILE_HDR="${OUTPUT_FILE_HDR}${LBTEST_METRICS}"
      fi
      
      if [[ $metric = "${METRIC_FILES[0]}" ]]; then
        OUTPUT_FILE_HDR="${OUTPUT_FILE_HDR}${APP_METRICS}"
      fi
      
      if [[ $metric = "${METRIC_FILES[1]}" ]]; then
        OUTPUT_FILE_HDR="${OUTPUT_FILE_HDR}${STEP_METRICS}"
      fi

      echo "${OUTPUT_FILE_HDR}" > "${OUTPUT_FILE}"
      
      for lb in ${LBs[@]}; do
        if [[ $app = "${APPs[0]}" ]]; then # LeanMD
          for period in "${LEANMD_PERIODS[@]}"; do
            FILE="${LEANMD_DIR}${app}_${period}_${lb}${IN_EXT}"

            if [[ $metric = "${METRIC_FILES[0]}" ]]; then
              parse_app_time $FILE $lb $period $app $OUTPUT_FILE
            else
              parse_step_time $FILE $lb $period $app $OUTPUT_FILE
            fi
          done
        fi
        if [[ $app = "${APPs[1]}" ]]; then # LbTest
          for topo in "${LBTEST_TOPOS[@]}"; do
            FILE="${LBTEST_DIR}${app}_${topo}_${lb}${IN_EXT}"

            if [[ $metric = "${METRIC_FILES[0]}" ]]; then
              parse_lbtest_app_time $FILE $lb $topo $app $OUTPUT_FILE
            fi
          done
        fi
      done 
    done
  done
}

############################# Execution flow ##############################
cd $(dirname "$0")/..
mkdir -p $BASE_DIR/$PARSE_DIR
rm -rf $BASE_DIR/$PARSE_DIR/*

create_headers