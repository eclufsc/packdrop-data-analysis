# Input Information

dir <-"/home/vinicius/packdrop-data-analysis/icpp2018/experiments" # state the directory of the workspace folder.
file <- "g5k-steptime.csv" # State the file within the data folder in dir.
mult <- 1 # Metrics are in microseconds, and we will plot them as 0-1000 values.

max_range <- 55
x_label <- "Number of PEs"
y_label <- "Mean Rescheduling Time (s)"
pdf_name <- "~/work-ecl-vinicius/packdrop-data-analysis/icpp2018/results/schedtime_leanmd_sdumont.pdf"

########
#full_file_name = paste(paste(dir, "/g5k/parsed-data/", sep=""), file, sep = "")
df = sdumont.apptime

library(plyr)  # biblioteca com a função ddply
df_no_greedy <- df[df$sched != "PackDropMigCost",]
df_no_greedy <- df_no_greedy[df_no_greedy$sched != "Refine",]
resumed_data <- ddply(df_no_greedy, .variables = c("sched", "plat_size", "wildmetric", "app"), summarize, mean = mean(app_time)*mult, median = median(app_time)*mult, stdev=sd(app_time)*mult, num = length(app_time))
resumed_data <- resumed_data[resumed_data$plat_size > 380,]
resumed_data <- resumed_data[resumed_data$plat_size < 1000,]
resumed_data <- resumed_data[resumed_data$app=="leanmd",]

## Terceiro passo: desenhar os resultados de tempo médio
library(ggplot2) # biblioteca para gráficos

# Definição do tema usado para a figura
mytheme2 <- theme_bw(base_size=40, base_family = "Times") +
  theme(panel.background=element_blank(), text = element_text(size=32),
        legend.position = "none",
        legend.title = element_blank(), 
        legend.key.size = unit(2, 'lines'),
        panel.grid.minor = element_line(colour = "light gray", size=0.1))

p1 <- ggplot(resumed_data, aes(x=plat_size, y=mean, group=sched)) +
  mytheme2 + ylim(c(0,3)) +
  xlab(x_label) + ylab(y_label) +
  geom_line(aes(linetype=sched, color=sched), size=2) + geom_point(aes(shape=sched, color=sched), size=4) +
  scale_x_continuous(breaks= (c(384, 480, 576, 672, 768)))
pdf(pdf_name)
print(p1)
dev.off()