##This file includes the first steps for conducting the quality control pipeline to upload the Affymetrix v6 array from the
##NCDS to the Michigan Imputation Server.

##Requirements:
	Affymetrix v6 array binary files, with exclusions and duplicates removed 
		(name affy.6)
	Plink 1.90b4
	R
	This script should be run in a unix environment


##Identify SNPs with high proportion of missing data. This document can be inspected if required.
plink --bfile affy.6 --missing --out affy.6.calls

##Remove SNPs with call rate < 0.97
plink --bfile affy.6 --geno 0.03 --make-bed --out affy.6.QC1

##Identify individuals with high proportion of missing data.
plink --bfile affy.6.QC1 --missing --out affy.6.calls.2
awk '$6 >= 0.02 {print}' affy.6.calls.2.imiss >> affy.6.drop.txt
plink --bfile affy.6.QC1 --remove affy.6.drop.txt --make-bed --out affy.6.QC2

##Check for unexpected levels of heterozygostiy - calculate heterozygostiy proportions.
plink --bfile affy.6.QC2 --het --out affy.6
plink --bfile affy.6.QC2 --missing --out affy.6.calls.3
echo "FID IID obs_HOM N_SNPs prop_HET" > affy.6.prop.het.txt
awk 'NR>1{print $1,$2,$3,$5,($5-$3)/$5}' affy.6.het >> affy.6.prop.het.txt

##Calculate plus and minus 3SD for heterozygosity
R
hetsd<- read.table("affy.6.prop.het.txt", header = T)
sd<- sd(hetsd[,5])
hetmean<- mean(hetsd[,5])
lbound<- hetmean - (sd*3)
ubound<- hetmean + (sd*3)
Stat<- c("SD2, "Lower Bound", "Uppder Bound", "Mean")
Values<- c(sd, lbound, ubound, hetmean)
affy.6.6.sd<- data.frame(Stat, Values)
write.table(affy.6.sd, file = "affy.6.sd.txt", row.names = F, quote = F, sep = "\t")
q()

##Note upper and lower bound, named x and y respectively here. Remove heterozygosity outliers.
'awk $5 <= y || $5 >= x' affy.6.prop.het.txt >> affy.6.het.drop.txt
plink --bfile affy.6.QC2 --remove affy.6.het.drop.txt --make-bed --out affy.6.QC3
