#Step 4 to prepare the Illumina Human 660-Quad array for imputation. 
#This section requires several external script - read below for requirements.

#Requirements
#	Plink 1.90b4
#	Perl
#	BCFtools
#	Python

#At this stage you may carry out principal components analysis for ancestry on the dataset if you 
#will be needing these values. 
plink --bfile quad.QC9 --indep-pairwise 1000 5 0.2 --out quad.QC9
plink --bfile quad.QC9 --extract quad.QC9.prune.in --make-bed --pca header tabs --out quad.pca

#Genetate allele frequencies from clean file.
plink --bfile quad.QC9 --freq --out quad

#Now check data using Will Rayner's checking script. Script and associated files are available here: 
#	https://www.well.ox.ac.uk/~wrayner/tools/
#Run using code:
perl HRC-1000G-check-bim.pl -b quad.QC9.bim -f quad.frq -r HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h

#Run the output script, Run-plink.sh, to clean the file.

#Convert all files to VCF format
for CHR in {1..23};
do
plink --bfile quad.QC9-updated-chr${CHR} --recode vcf --out quad.updated.chr${CHR}
bcftools sort quad.updated.chr${CHR}.vcf -O z -o quad.chr${CHR}.vcf.gz
done

#OPTIONAL: check VCF files are valid using this script https://github.com/zhanxw/checkVCF



