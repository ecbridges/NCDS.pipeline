#This is step 3 for the preparation of the Illumina 1.2 million array. This section will clean up
#the updated dataset by addressing any sex errors, related individuals and heterozygrous haploid
#loci.

#Requirements
#	Plink 1.90b4
#	Illumina 1.2 million array updated to build GRCh37 (name illumina.1.2.QC4)

#Ensure PAR variants are properly assigned.
plink --bfile illumina.1.2.QC4 --split-x b37 no-fail --make-bed --out illumina.1.2.QC5

#Set remaining .hh instances to missing.
plink --bfile illumina.1.2.QC5 --set-hh-missing --make-bed --out illumina.1.2.QC6

#Ensure chromosomes are properly coded.
plink --bfile illumina.1.2.QC6 --merge-x --make-bed --out illumina.1.2.QC7plink --bfile illumina.1.2.QC6 --merge-x --make-bed --out illumina.1.2.QC7

#Sex check on pruned dataset.
plink --bfile illumina.1.2.QC7 --indep-pairwise 1000 5 0.2 --out illumina.1.2.QC7
plink --bfile illumina.1.2.QC7 --extract illumina.1.2.QC7plink --bfile illumina.1.2.QC7 --indep-pairwise 1000 5 0.2 --out illumina.1.2.QC7
plink --bfile illumina.1.2.QC7 --extract illumina.1.2.QC7.prune.in --check-sex --out illumina.1.2.sex
grep PROBLEM illumina.1.2.sex.sexcheck >> illumina.1.2.sex.probs.txt
.prune.in --check-sex --out illumina.1.2.sex
grep PROBLEM illumina.1.2.sex.sexcheck >> illumina.1.2.sex.probs.txt

#Remove individuals with sex errors.
plink --bfile illumina.1.2.QC7 --remove illumina.1.2.sex.probs.txt --make-bed --out illumina.1.2.QC8

#Check for related individuals.
plink --bfile illumina.1.2.QC8 --indep-pairwise 1500 150 0.2 --out illumina.1.2.QC8
plink --bfile illumina.1.2.QC8 --extract illumina.1.2.QC8.prune.in --make-bed --out pruned.illumina.1.2.QC8
plink --bfile pruned.illumina.1.2.QC8 --genome --out illumina.1.2
awk '$10 >= 0.1875 {print}' illumina.1.2.genome > illumina.1.2.related.txt

#Check each related pair of individuals. Create text file, illumina.1.2.related.excl.txt, containing FID
#and IID of each individual to be removed.
plink --bfile illumina.1.2.QC8 --remove illumina.1.2.related.excl.txt --make-bed --out illumina.1.2.QC9


 
