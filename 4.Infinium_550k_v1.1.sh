#Step 4 to prepare the Infinium 500k v1.1 array for imputation. This section requires several external script - read below for requirements.

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
#For all NCDS arrays, a theta of 3 was used rather than the default of 1.5.
#Place outliers in a file named infin.1.ancestry.txt

#Remove ancestry outliers.
plink --bfile infin.1.QC9 --remove infin.1.ancestry.txt --make-bed --out infin.1.QC10plink --bfile infin.1.QC9 --remove infin.1.ancestry.txt --make-bed --out infin.1.QC10

#At this stage you may carry out principal components analysis for ancestry on the dataset if you 
#will be needing these values. 
plink --bfile infin.1.QC10 --indep-pairwise 1000 5 0.2 --out infin.1.QC10
plink --bfile infin.1.QC10 --extract infin.1.QC10.prune.in --make-bed --pca header tabs --out infin.1.pca

#Genetate allele frequencies from clean file.
plink --bfile infin.1.QC10 --freq --out infin.1

#Now check data using Will Rayner's checking script. Script and associated files are available here: 
#	https://www.well.ox.ac.uk/~wrayner/tools/
#Run using code:
perl HRC-1000G-check-bim.pl -b infin.1.QC10.bim -f infin.1.frq -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

#Run the output script, Run-plink.sh, to clean the file.

#Convert all files to VCF format
for CHR in {1..23};
do
plink --bfile infin.1.QC10-updated-chr${CHR} --recode vcf --out infin.1.updated.chr${CHR}
bcftools sort infin.1.updated.chr${CHR}.vcf -O z -o infin.1.chr${CHR}.vcf.gz
done

#OPTIONAL: check VCF files are valid using this script https://github.com/zhanxw/checkVCF



