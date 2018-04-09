# Input Information

dir <-"/home/vinicius/packdrop-data-analysis/icpp2018/experiments" # state the directory of the workspace folder.
file <- "leanmd_apptime.csv" # State the file within the data folder in dir.
mult <- 1 # Metrics are in microseconds, and we will plot them as 0-1000 values.

max_range <- 55
x_label <- "Rescheduling Period"
y_label <- "Mean Application Time (s)"
pdf_name <- "~/packdrop-data-analysis/apptime_leanmd_g5k.pdf"

########
full_file_name = paste(paste(dir, "/g5k/parsed-data/", sep=""), file, sep = "")
df = read.csv(full_file_name)

library(plyr)  # biblioteca com a função ddply
df_no_greedy <- df[df$sched != "greedy",]
resumed_data <- ddply(df_no_greedy, .variables = c("sched", "period", "app"), summarize, mean = mean(app_time)*mult, median = median(app_time)*mult, stdev=sd(app_time)*mult, num = length(app_time))

## Terceiro passo: desenhar os resultados de tempo médio
library(ggplot2) # biblioteca para gráficos

# Definição do tema usado para a figura
mytheme2 <- theme_bw(base_size=14, base_family = "Times") +
  theme(panel.background=element_blank(),
        legend.title = element_blank(), 
        panel.grid.minor = element_line(colour = "light gray", size=0.1))

p1 <- ggplot(resumed_data, aes(factor(period), mean, fill = sched)) +
  mytheme2 +
  xlab(x_label) + ylab(y_label) +
  geom_bar(stat="identity", position = "dodge", colour="black") + 
  scale_fill_brewer(palette = "Blues", labels = (c("Distributed", "Dummy", "PackDrop", "Refine"))) +
  scale_x_discrete(labels= (c("Long", "Short"))) +
  scale_y_continuous(breaks= (c(10, 30, 50, 70, 90, 110)))
pdf(pdf_name)
print(p1)
dev.off()