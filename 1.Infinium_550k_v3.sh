##This file includes the first steps for conducting the quality control pipeline to upload the Infinium 550k v3 array from the
##NCDS to the Michigan Imputation Server.

##Requirements:
	Infinium 550k v3  array binary files, with exclusions and duplicates removed 
		(name infin.3)
	Plink 1.90b4
	R
	This script should be run in a unix environment


##Identify SNPs with high proportion of missing data. This document can be inspected if required.
plink --bfile infin.3 --missing --out infin.3.calls

##Remove SNPs with call rate < 0.97
plink --bfile infin.3 --geno 0.03 --make-bed --out infin.3.QC1

##Identify and remove variants not in HWE.
plink --bfile infin.3.QC1 --hardy --out infin.3
awk '$3 == "UNAFF" && $9 < 0.000001' infin.3.hwe | wc -l
plink --bfile infin.3.QC1 --hwe 0.000001 --make-bed --out infin.3.QC2

##Identify individuals with high proportion of missing data.
plink --bfile infin.3.QC2 --missing --out infin.3.calls.2
awk '$6 >= 0.02 {print}' infin.3.calls.2.imiss >> infin.3.drop.txt
plink --bfile infin.3.QC2 --remove infin.3.drop.txt --make-bed --out infin.3.QC3

##Check for unexpected levels of heterozygostiy - calculate heterozygostiy proportions.
plink --bfile infin.3.QC3 --het --out infin.3.QC3
plink --bfile infin.3.QC3 --missing --out infin.3.calls.3
echo "FID IID obs_HOM N_SNPs prop_HET" > infin.3.prop.het.txt
awk 'NR>1{print $1,$2,$3,$5,($5-$3)/$5}' infin.3.QC3.het >> infin.3.prop.het.txt

##Calculate plus and minus 3SD for heterozygosity
R
hetsd<- read.table("infin.3.prop.het.txt", header = T)
sd<- sd(hetsd[,5])
hetmean<- mean(hetsd[,5])
lbound<- hetmean - (sd*3)
ubound<- hetmean + (sd*3)
Stat<- c("SD", "Lower Bound", "Upper Bound", "Mean")
Values<- c(sd, lbound, ubound, hetmean)
infin.3.sd<- data.frame(Stat, Values)
write.table(infin.3.sd, file = "infin.3.sd.txt", row.names = F, quote = F, sep = "\t")
q()

##Remove heterozygosity outliers.
awk '$5 <= 0.319 || $5 >= 0.333' infin.awk '$5 <= 0.319 || $5 >= 0.333' infin.3.prop.het.txt >> infin.3.het.drop.txt
plink --bfile infin.3.QC3 --remove infin.3.het.drop.txt --make-bed --out infin.3.QC4
