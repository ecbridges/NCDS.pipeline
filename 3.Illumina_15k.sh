#This is step 3 for the preparation of the Illumina 15k array. This section will clean up
#the updated dataset by addressing any sex errors, related individuals and heterozygrous haploid
#loci.

#Requirements
#	Plink 1.90b4
#	Illumina 15k million array updated to build GRCh37 (name illumina.15.QC4)

#Ensure PAR variants are properly assigned.
plink --bfile illumina.15.QC4 --split-x b37 no-fail --make-bed --out illumina.15.QC5

#Set remaining .hh instances to missing.
plink --bfile illumina.15.QC5 --set-hh-missing --make-bed illumina.15.QC6

#Sex check on pruned dataset.
plink --bfile illumina.15.QC6 --indep-pairwise 1000 5 0.2 --out illumina.15.QC6
plink --bfile illumina.15.QC6 --extract illumina.15.QC6.prune.in --sex-check --out illumina.15.sex
grep PROBLEM illumina.15.sex.sexcheck >> illumina.15.sex.probs.txt

#Remove individuals with sex errors.
plink --brfile illumina.15.QC6 --remove illumina.15.sex.probs.txt --make-bed --out illumina.15.QC7

#Check for related individuals.
plink --bfile illumina.15.QC7 --indep-pairwise 1500 150 0.2 --out illumina.15.QC7
plink --bfile illumina.15.QC7 --extract illumina.15.QC7.prune.in --make-bed --out pruned.illumina.15.QC7
plink --bfile pruned.illumina.15.QC7 --genome --out illumina.15
awk '$10 >= 0.1875 {print}' illumina.15.genome > illumina.15.related.txt

#Check each related pair of individuals. Create text file, illumina.1.2.related.excl.txt, containing FID
#and IID of each individual to be removed. We removed the individual with the most missing data.
plink --bfile illumina.15.QC7 --remove illumina.15.related.excl.txt --make-bed --out illumina.15.QC8


