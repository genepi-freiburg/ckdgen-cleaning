args = commandArgs(trailingOnly=T)
infile = args[1]
title = args[2]
outfile = args[3]

data = read.table(infile, h=T)
summary(data)

png(outfile)
plot(1:nrow(data), data$position, xlab="Row index", ylab="Position", main=title)
dev.off()
