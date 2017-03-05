
args <- commandArgs(TRUE) # Capturing command line arguments
data <- args[1]  # first argument is input (processed) data
out <- args[2]  # second argument is desired file name for plot

norm <- read.csv(file=data,header=T)  # Reading processed data

png(filename = out)  # recording plot into png
plot(norm[,1],norm[,2])  # plotting processed data
dev.off()  # EOF