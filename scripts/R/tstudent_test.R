# Input Information

dir <-"/home/alexandre/git/MOGSLib-data-analysis" # state the directory of the workspace folder.
file <- "execution_time.csv" # State the file within the data folder in dir.

set.seed(42)
datacount = 50
grouping = 5

#######
library(plyr)

full_file_name = paste(paste(dir, "/data/charm/parsed_logs/", sep=""), file, sep = "")
df = read.csv(full_file_name)

aggregate_data <- function(data) {
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
  
  return(datagroups)
}

aggregated_data <- df[!(grepl("NoLB", df$sched)),]

aggregated_data <- ddply(aggregated_data, .variables = c("load", "sched"), summarise, aggregated = aggregate_data(metric))

test_t = array()
i = 1
for(taskc in c(300, 600, 900, 1200)) {
  greedy = aggregated_data[which(aggregated_data$load==taskc & aggregated_data$sched=="Greedy"),]
  lib = aggregated_data[which(aggregated_data$load==taskc & aggregated_data$sched=="Lib"),] 
  test_t[i] = t.test(greedy$aggregated, lib$aggregated, alternative = "two.sided" )$p.value
  i = i + 1
}


