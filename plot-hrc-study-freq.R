library("ggplot2")
library("hexbin")

args = commandArgs(trailingOnly = TRUE)

print(paste("Reading file:", args[1]))
d = read.table(args[1])
colnames(d) = c("var", "hrc_af", "study_af")

print("Calculate MAF for study")
d$study_maf = ifelse(d$study_af > 0.5, 1 - d$study_af, d$study_af)

print("Calculating MAF for HRC")
d$hrc_maf = ifelse(d$hrc_af > 0.5, 1 - d$hrc_af, d$hrc_af)

print("Data summary")
summary(d)

pdf(paste(args[0], "-scatter.pdf", sep=""))
ggplot(d, aes(x=hrc_maf, y=study_maf)) + stat_binhex()

