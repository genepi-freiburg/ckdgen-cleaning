#chr	position	noncoded_all	coded_all	AF_coded_all	beta	pvalue
#7	1285195	A	T	0.3223	-0.0046111	0.77134
#trait	ethnicity	SNP	gene	chr	pos	ref	alt	MAF_1KGP	direction_alt
#eGFR	EAS	rs10277115	UNCX	7	1285195	A	T	0,31	neg


args = commandArgs(TRUE)


study = read.table(args[1], h=T, colClasses = c("character"))
posit = read.table(args[2], h=T, colClasses = c("character"))
study$chr = as.numeric(study$chr)
posit$chr = as.numeric(posit$chr)
result = merge(study, posit, by.x=c("chr", "position"), by.y=c("chr", "position"))

result$beta = as.numeric(result$beta)
result$AF_coded_all = as.numeric(result$AF_coded_all)
result$MAF_1KGP = as.numeric(result$MAF_1KGP)

head(result)

for (i in 1:nrow(result)) {
	print(paste("Check control #", i, sep=""))

	if (result[i,]$noncoded_all != result[i,]$ref) {
		print("REF allele MISMATCH")
	} else {
		print("REF allele matches")
	}

	if (result[i,]$coded_all != result[i,]$alt) {
		print("ALT allele MISMATCH")
	} else {
		print("ALT allele matches")
	}

	if (result[i,]$beta < 0 && result[i,]$direction_alt == "neg") {
		print("Direction matches")
	} else if (result[i,]$beta > 0 && result[i,]$direction_alt == "pos") {
		print("Direction matches")
	} else {
		print("Direction MISMATCH")
	}

	snp_maf = result[i,]$AF_coded_all
	if (snp_maf > 0.5) {
		snp_maf = 1 - snp_maf
	}

	print(paste("SNP MAF:", snp_maf))
	diff = snp_maf - result[i,]$MAF_1KGP
	print(paste("Diff:", abs(diff)))
	if (abs(diff) > 0.1) {
		print("Frequency DEVIATION")
	} else {
		print("Frequency matches")
	}
}

print("Finish")
