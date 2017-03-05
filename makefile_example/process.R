 
args <- commandArgs(TRUE)  # Capturing command line arguments
data <- args[1]  # first argument is input file
out <- args[2]  # second argument is output file

raw <-read.csv(file = data, header = T)  # Read input
norm <- as.data.frame(scale(raw))  # process data
write.csv(norm,file = out,row.names = F)  # write output