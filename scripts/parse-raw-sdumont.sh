#!/bin/bash

# Experiment Constants
declare -a LBs=("distributed" "greedy" "nolb" "packdrop" "refine")
declare -a APPs=("leanmd" "lbtest")

# Output Content
# This script assumes these variables are static...
# They are here presented for better readability, any changes on them must be met with changes to the respectives functions "parse_app_time" and "parse_step_time"
declare -a METRIC_FILES=("apptime" "steptime")
declare -a STEP_METRICS=("step_time")
declare -a APP_METRICS=("app_time")
declare -a COMMON_METRICS=("sched")

# Organization constants
declare -a IN_EXT=".out" # Input file extension
declare -a BASE_DIR="experiments/sdumont" # Experiments directory
declare -a RAW_DIR="raw-data" # Raw data subdirectory

#Output constants
declare -a OUT_EXT=".csv" # Output file extension
declare -a PARSE_DIR="parsed-data" # Parsed data subdirectory
declare -a OUTPUT_FILES=() # A list of output files created dynamically by the "init_outfiles" functions