# Input Information

dir <-"/home/alexandre/git/MOGSLib-data-analysis" # state the directory of the workspace folder.
file <- "decision_time.csv" # State the file within the data folder in dir.
rts <- "charm"

set.seed(576)
datacount = 150
grouping = 15

#######
library(plyr)

full_file_name = paste(paste(dir, "/data/charm/parsed_logs/", sep=""), file, sep = "")
df = read.csv(full_file_name)

aggregate_and_test <- function(data) {
  data_size = datacount
  aggregation_size = grouping
  
  datagroups_size = data_size/aggregation_size
  rand_idx = sample(1:data_size)
  
  datagroups = array()
  
  for(datagroup in 1:datagroups_size) {
    sum = 0;
    for(sample in 1:aggregation_size) {
      sum = sum + data[rand_idx[(datagroup-1)*aggregation_size + sample]]
    }
    datagroups[datagroup] = sum/aggregation_size
  }
  
  return(shapiro.test(datagroups)$p.value)
}

resumed_data <- ddply(df, .variables = c("load", "sched"), summarise, ntest = aggregate_and_test(metric))