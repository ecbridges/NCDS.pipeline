#Step 4 to prepare the Affymetrix v6 array for imputation. This section requires several external script - read below for requirements.

#Requirements
#	Plink 1.90b4
#	Plink 2
#	R, including the package "plinkQC"
#	Perl
#	BCFtools
#	Python

#The first step is to identify ancestry outliers, by merging the data with a reference panel and 
#locating the outliers.
#Follow this procedure to download the 1000 Genomes reference panel: https://meyer-lab-cshl.github.io/plinkQC/articles/Genomes1000.html
#Follow this procedure to identify ancestry outliers: https://meyer-lab-cshl.github.io/plinkQC/articles/AncestryCheck.html
#For all NCDS arrays, a theta of 3 was used rather than the default of 1.5, using the code below.

R 
library(plinkQC) 
exclude_ancestry.affy.6 <-  evaluate_check_ancestry(indir="", name="",
                          prefixMergedDataset=,
                          europeanTh = 3,
                          refSamplesFile=paste(indir=system.file(package = "plinkQC"), 
"/extdata/Genomes1000_ID2Pop.txt",
                                               sep=""),
                          refColorsFile=paste(indir=system.file(package = "plinkQC"), 
"/extdata/Genomes1000_PopColors.txt",
                                              sep=""),
                          interactive=TRUE)

write.table(file = "affy.6.ancestry.txt", exclude_ancestry.affy.6$fail_ancestry, 
	    row.names = F, quote = F)

#Remove ancestry outliers.
plink --bfile affy.6.QC8 --remove affy.6.ancestry.txt --make-bed --out affy.6.QC9

#At this stage you may carry out principal components analysis for ancestry on the dataset if you 
#will be needing these values. 
plink --bfile affy.6.QC9 --indep-pairwise 1000 5 0.2 --out affy.6.QC9
plink --bfile affy.6.QC9 --extract affy.6.QC9.prune.in --make-bed --pca header tabs --out affy.6.pca

#Genetate allele frequencies from clean file.
plink --bfile affy.6.QC9 --freq --out affy.6

#Now check data using Will Rayner's checking script. Script and associated files are available here: 
#	https://www.well.ox.ac.uk/~wrayner/tools/
#Run using code:
perl HRC-1000G-check-bim.pl -b affy.6.QC9.bim -f affy.6.frq -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

#Run the output script, Run-plink.sh, to clean the file.

#Convert all files to VCF format
for CHR in {1..23};
do
plink --bfile affy.6.QC9-updated-chr${CHR} --recode vcf --out affy.6.updated.chr${CHR}
bcftools sort affy.6.updated.chr${CHR}.vcf -O z -o affy.6.chr${CHR}.vcf.gz
done

#OPTIONAL: check VCF files are valid using this script https://github.com/zhanxw/checkVCF



