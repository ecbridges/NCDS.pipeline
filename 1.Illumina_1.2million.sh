plink --bfile illumia.1.2.QC1 --missing --out illumina.1.2.calls.2
##This file includes the first steps for conducting the quality control pipeline to upload the Illumina 1.2 million array from the
##NCDS to the Michigan Imputation Server.

##Requirements:
	Illumina 1.2 million array binary files, with exclusions and duplicates removed 
		(name illumina.1.2)
	Plink 1.90b4
	R
	This script should be run in a unix environment


##Identify SNPs with high proportion of missing data. This document can be inspected if required.
plink --bfile illumina.1.2 --missing --out illumina.1.2.calls

##Remove SNPs with call rate < 0.97
plink --bfile illumina.1.2 --geno 0.03 --make-bed --out illumina.1.2.QC1

##Identify individuals with high proportion of missing data.
plink --bfile illumina.1.2.QC1 --missing --out illumina.1.2.calls.2
awk '$6 >= 0.02 {print}' illumina.1.2.calls.2.imiss >> illumina.1.2.drop.txt
plink --bfile illumina.1.2.QC1 --remove illumina.1.2.drop.txt --make-bed --out illumina.1.2.QC2

##Check for unexpected levels of heterozygostiy - calculate heterozygostiy proportions.
plink --bfile illumina.1.2.QC2 --het --out illumina.1.2
plink --bfile illumina.1.2.QC2 --missing --out illumina.1.2.calls.3
echo "FID IID obs_HOM N_SNPs prop_HET" > illumina.1.2.prop.het.txt
awk 'NR>1{print $1,$2,$3,$5,($5-$3)/$5}' illumina.1.2.het >> illumina.1.2.prop.het.txt

##Calculate plus and minus 3SD for heterozygosity
R
hetsd<- read.table("illumina.1.2.prop.het.txt", header = T)
sd<- sd(hetsd[,5])
hetmean<- mean(hetsd[,5])
lbound<- hetmean - (sd*3)
ubound<- hetmean + (sd*3)
Stat<- c("SD", "Lower Bound", "Uppqer Bound", "Mean")
Values<- c(sd, lbound, ubound, hetmean)
illumina.1.2.sd<- data.frame(Stat, Values)
write.table(illumina.1.2.sd, file = "illumina.1.2.sd.txt", row.names = F, quote = F, sep = "\t")
q()

#Remove heterozygosity outliers.
awk '$5 <= 0.288 || $5 >= 0.303' illumina.1.2.prop.het.txt >> illumina.1.2.het.drop.txt
plink --bfile illumina.1.2.QC2 --remove illumina.1.2.het.drop.txt --make-bed --out illumina.1.2.QC3
