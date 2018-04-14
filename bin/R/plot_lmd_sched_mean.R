# Input Information

dir <-"/home/vinicius/packdrop-data-analysis/icpp2018/experiments" # state the directory of the workspace folder.
file <- "g5k-steptime.csv" # State the file within the data folder in dir.
mult <- 1000 # Metrics are in microseconds, and we will plot them as 0-1000 values.

max_range <- 55
x_label <- "Number of PEs"
y_label <- "Mean Rescheduling Time (ms)"
pdf_name <- "~/packdrop-data-analysis/icpp2018/results/schedtime_leanmd_sdumont.pdf"

########
#full_file_name = paste(paste(dir, "/g5k/parsed-data/", sep=""), file, sep = "")
df = sdumont.schedtime

library(plyr)  # biblioteca com a função ddply
df_no_greedy <- df[df$sched != "PackDropMigCost",]
resumed_data <- ddply(df_no_greedy, .variables = c("sched", "plat_size", "wildmetric", "app"), summarize, mean = mean(sched_time)*mult, median = median(sched_time)*mult, stdev=sd(sched_time)*mult, num = length(sched_time))
resumed_data <- resumed_data[resumed_data$plat_size > 380,]
resumed_data <- resumed_data[resumed_data$plat_size < 1000,]
resumed_data <- resumed_data[resumed_data$app=="leanmd",]

## Terceiro passo: desenhar os resultados de tempo médio
library(ggplot2) # biblioteca para gráficos

# Definição do tema usado para a figura
mytheme2 <- theme_bw(base_size=14, base_family = "Times") +
  theme(panel.background=element_blank(), text = element_text(size=20),
        legend.title = element_blank(), 
        panel.grid.minor = element_line(colour = "light gray", size=0.1))

p1 <- ggplot(resumed_data, aes(x=plat_size, y=mean, group=sched)) +
  mytheme2 +
  xlab(x_label) + ylab(y_label) +
  geom_line(aes(linetype=sched, color=sched)) + geom_point(aes(shape=sched, color=sched)) +
  scale_x_continuous(breaks= (c(384, 480, 576, 672, 768)))
pdf(pdf_name)
print(p1)
dev.off()