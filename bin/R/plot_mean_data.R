# Input Information

dir <-"/home/alexandre/git/MOGSLib-data-analysis" # state the directory of the workspace folder.
file <- "decision_time.csv" # State the file within the data folder in dir.
mult <- 1000000 # Metrics are in microseconds, and we will plot them as 0-1000 values.

max_range <- 800
y_label <- "Strategy Mean Decision Time (us)"
pdf_name <- "~/Desktop/decision_time_charm.pdf"

########
full_file_name = paste(paste(dir, "/data/charm/parsed_logs/", sep=""), file, sep = "")
df = read.csv(full_file_name)

library(plyr)  # biblioteca com a função ddply
df_no_binlpt <- df[df$sched != "BinLPT",]
resumed_data <- ddply(df_no_binlpt, .variables = c("load", "sched"), summarize, mean = mean(metric)*mult, median = median(metric)*mult, stdev=sd(metric)*mult, num = length(metric))

## Terceiro passo: desenhar os resultados de tempo médio
library(ggplot2) # biblioteca para gráficos

# Definição do tema usado para a figura
mytheme2 <- theme_bw(base_size=14, base_family = "Times") +
  theme(panel.background=element_blank(),
        legend.title = element_blank(), 
        panel.grid.minor = element_blank())

p1 <- ggplot(resumed_data, aes(factor(load), mean, fill = sched)) +
  mytheme2 +
  ylim(0,max_range) +
  xlab("Task Count") + ylab(y_label) +
  geom_bar(stat="identity", position = "dodge", colour="black") + 
  scale_fill_brewer(palette = "Blues", labels = (c("GreedyLB", "MOGSLibLB")))
pdf(pdf_name)
print(p1)
dev.off()