# Input Information

dir <-"/home/alexandre/git/MOGSLib-data-analysis" # state the directory of the workspace folder.
file <- "decision_time.csv" # State the file within the data folder in dir.

mult <- 1000000 # Metrics are in microseconds, and we will plot them as 0-1000 values.

#######
library(ggplot2)

full_file_name = paste(paste(dir, "/data/charm/parsed_logs/", sep=""), file, sep = "")
df = read.csv(full_file_name)

df["metric"] <- df["metric"] * 1000
greedy_data <-df[df$sched == "Greedy",]
lib_data <-df[df$sched == "Lib",]
binlpt_data <-df[df$sched == "BinLPT",]

greedy_lm <- lm(metric ~ load, data = greedy_data)
lib_lm <- lm(metric ~ load, data = lib_data)
binlpt_lm <- lm(metric ~ load, data = binlpt_data)

print(greedy_lm)
print(lib_lm)
print(binlpt_lm)