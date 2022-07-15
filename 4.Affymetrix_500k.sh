#Step 4 to prepare the Affymetrix 500k array for imputation. This section requires several external script - read below for requirements.

#Requirements
#	Plink 1.90b4
#	Plink 2
#	Perl
#	BCFtools
#	Python

#At this stage you may carry out principal components analysis for ancestry on the dataset if you 
#will be needing these values. 
plink --bfile affy.500.QC6 --indep-pairwise 1000 5 0.2 --out affy.500.QC6
plink --bfile affy.500.QC6 --extract affy.500.QC6.prune.in --make-bed --pca header tabs --out affy.500.QC6.pca

#Genetate allele frequencies from clean file.
plink --bfile affy.500.QC6 --freq --out affy.500

#Now check data using Will Rayner's checking script. Script and associated files are available here: 
#	https://www.well.ox.ac.uk/~wrayner/tools/
#Run using code:
perl HRC-1000G-check-bim.pl -b affy.500.QC6.bim -f affy.500.frq -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

#Run the output script, Run-plink.sh, to clean the file.

#Convert all files to VCF format
for CHR in {1..22};
do
plink --bfile affy.500.QC6-updated-chr${CHR} --recode vcf --out affy.500.updated.chr${CHR}
bcftools sort affy.500.updated.chr${CHR}.vcf -O z -o affy.500.chr${for CHR in {1..22};
do
plink --bfile affy.500.QC6-updated-chr${CHR} --recode vcf --out affy.500.updated.chr${CHR}
bcftools sort affy.500.updated.chr${CHR}.vcf -O z -o affy.500.chr${CHR}.vcf.gz
doneCHR}.vcf.gz
done

#OPTIONAL: check VCF files are valid using this script https://github.com/zhanxw/checkVCF



