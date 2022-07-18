##This file includes the first steps for conducting the quality control pipeline to upload the Affymetrix 500k array from the
##NCDS to the Michigan Imputation Server.

##Requirements:
	Affymetrix 500k  array binary files, with exclusions and duplicates removed 
		(name affy.500)
	Plink 1.90b4
	R
	This script should be run in a unix environment


##Identify SNPs with high proportion of missing data. This document can be inspected if required.
plink --bfile affy.500 --missing --out affy.500

##Remove SNPs with call rate < 0.97
plink --bfile affy.500 --geno 0.03 --make-bed --out affy.500.QC1

##Identify and remove variants not in HWE.
plink --bfile affy.500.QC1 --hardy --out affy.500
awk '$3 == "UNAFF" && $9 < 0.000001' affy.500.hwe | wc -l
plink --bfile affy.500.QC1 --hwe 0.000001 --make-bed --out affy.500.QC2

##Check for unexpected levels of heterozygostiy - calculate heterozygostiy proportions.
plink --bfile affy.500.QC2 --het --out affy.500.QC2
plink --bfile affy.500.QC2 --missing --out affy.500.calls.3
echo "FID IID obs_HOM N_SNPs prop_HET" > affy.500.prop.het.txt
awk 'NR>1{print $1,$2,$3,$5,($5-$3)/$5}' affy.500.QC2.het >> affy.500.prop.het.txt

##Calculate plus and minus 3SD for heterozygosity
R
hetsd<- read.table("affy.500.prop.het.txt", header = T)
sd<- sd(hetsd[,5])
hetmean<- mean(hetsd[,5])
lbound<- hetmean - (sd*3)
ubound<- hetmean + (sd*3)
Stat<- c("SD", "Lower Bound", "Upper Bound", "Mean")
Values<- c(sd, lbound, ubound, hetmean)
affy.500.sd<- data.frame(Stat, Values)
write.table(affy.500.sd, file = "affy.500.sd.txt", row.names = F, quote = F, sep = "\t")
q()

##Remove heterozygosity outliers.
awk '$5 <= 0.286 || $5 >= 0.300' affy.500.prop.het.txt >> affy.500.het.drop.txt
plink --bfile affy.500.QC2 --remove affy.500.het.drop.txt --make-bed --out affy.500.QC3
