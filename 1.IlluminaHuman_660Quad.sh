##This file includes the first steps for conducting the quality control pipeline to upload the Illumina Human
# 660-Quad array from the NCDS to the Michigan Imputation Server.

##Requirements:
	Illumina Human 660-Quad array binary files, with exclusions and duplicates removed 
		(name quad)
	Plink 1.90b4
	R
	This script should be run in a unix environment


##Identify SNPs with high proportion of missing data. This document can be inspected if required.
plink --bfile quad --missing --out quad.calls

##Remove SNPs with call rate < 0.97
plink --bfile quad --geno 0.03 --make-bed --out quad.QC1

##Identify individuals with high proportion of missing data.
plink --bfile quad.QC1 --missing --out quad.calls.2
awk '$6 >= 0.02 {print}' quad.calls.2.imiss >> quad.drop.txt
plink --bfile quad.QC1 --remove quad.drop.txt --make-bed --out quad.QC2

##Check for unexpected levels of heterozygostiy - calculate heterozygostiy proportions.
plink --bfile quad.QC2 --het --out quad
plink --bfile quad.QC2 --missing --out quad.calls.3
echo "FID IID obs_HOM N_SNPs prop_HET" > quad.prop.het.txt
awk 'NR>1{print $1,$2,$3,$5,($5-$3)/$5}' quad.het >> quad.prop.het.txt

##Calculate plus and minus 3SD for heterozygosity
R
hetsd<- read.table("quad.prop.het.txt", header = T)
sd<- sd(hetsd[,5])
hetmean<- mean(hetsd[,5])
lbound<- hetmean - (sd*3)
ubound<- hetmean + (sd*3)
Stat<- c("SD", "Lower Bound", "Upper Bound", "Mean")
Values<- c(sd, lbound, ubound, hetmean)
quad.sd<- data.frame(Stat, Values)
write.table(quad.sd, file = "quad.sd.txt", row.names = F, quote = F, sep = "\t")
q()

##Note upper and lower bound, named x and y respectively here. Remove heterozygosity outliers.
awk '$5 <= y || $5 >= x' quad.prop.het.txt >> quad.het.drop.txt
plink --bfile quad.QC2 --remove quad.het.drop.txt --make-bed --out quad.QC3
