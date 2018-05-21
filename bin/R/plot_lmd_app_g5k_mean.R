# Input Information

dir <-"/home/vinicius/packdrop-data-analysis/icpp2018/experiments" # state the directory of the workspace folder.
file <- "leanmd_steptime.csv" # State the file within the data folder in dir.
mult <- 1 # Metrics are in microseconds, and we will plot them as 0-1000 values.

max_range <- 55
x_label <- "Communication Topology"
y_label <- "Mean Application Time (s)"
pdf_name <- "~/work-ecl-vinicius/packdrop-data-analysis/icpp2018/results/apptime_lbtest_g5k.pdf"

########
#full_file_name = paste(paste(dir, "/g5k/parsed-data/", sep=""), file, sep = "")
#df = read.csv(full_file_name)

df = g5k.apptime
library(plyr)  # biblioteca com a função ddply
df_no_greedy <- df[df$sched != "greedy",]
resumed_data <- ddply(df, .variables = c("app", "sched", "plat_size", "wildmetric"), summarize, mean = mean(app_time)*mult, median = median(app_time)*mult, stdev=sd(app_time)*mult, num = length(app_time))

## Terceiro passo: desenhar os resultados de tempo médio
library(ggplot2) # biblioteca para gráficos

# Definição do tema usado para a figura
mytheme2 <- theme_bw(base_size=36, base_family = "Times") +
  theme(panel.background=element_blank(),
        legend.title = element_blank(),
        legend.position = (c(0.75,0.24)),
        legend.key.size = unit(2, 'lines'))
#        panel.grid.minor = element_line(colour = "light gray", size=0.1))

p1 <- ggplot(resumed_data, aes(factor(wildmetric), mean, fill = sched)) +
  mytheme2 +
  xlab(x_label) + ylab(y_label) +
  geom_bar(stat="identity", position = "dodge", colour="black") + 
  scale_fill_brewer(palette = "Spectral") +
  scale_y_continuous(breaks= (c(10, 20, 30, 40, 50, 60)))
pdf(pdf_name)
print(p1)
dev.off()