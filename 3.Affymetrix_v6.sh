plink --bfile affy.6.QC4 --split-x b37 no-fail --make-bed --out affy.6.QC5
#This is step 3 for the preparation of the Illumina 1.2 million array. This section will clean up
#the updated dataset by addressing any sex errors, related individuals and heterozygrous haploid
#loci.

#Requirements
#	Plink 1.90b4
#	Illumina 1.2 million array updated to build GRCh37 (name illumina.1.2.QC4)

#Ensure PAR variants are properly assigned.
plink --bfile affy.6.QC4 --split-x b37 no-fail --make-bed --out affy.6.QC5

#Set remaining .hh instances to missing.
plink --bfile affy.6.QC5 --set-hh-missing --make-bed --out affy.6.QC6

#Recode for compatibility.
plink --bfile affy.6.QC6 --merge-x --make-bed --out affy.6.QC7plink --bfile affy.6.QC6 --merge-x --make-bed --out affy.6.QC7
plink --bfile affy.6.QC7 --remove affy.6.sex.probs.txt --make-bed --out affy.6.QC8

#Sex check on pruned dataset.
plink --bfile affy.6.QC7 --indep-pairwise 1000 5 0.2 --out affy.6.QC7
plink --bfile affy.6.QC7 --extract affy.6.QC7.prune.in --check-sex --out affy.6.sex
grep PROBLEM affy.6.sex.sexcheck >> affy.6.sex.probs.txt


#Remove individuals with sex errors.
plink --bfile affy.6.QC7 --remove affy.6.sex.probs.txt --make-bed --out affy.6.QC8

#Check for related individuals.
plink --bfile affy.6.QC8 --indep-pairwise 1500 150 0.2 --out affy.6.QC8
plink --bfile affy.6.QC8 --extract affy.6.QC8.prune.in --make-bed --out pruned.affy.6.QC8
plink --bfile pruned.affy.6.QC8 --genome --out affy.6
awk '$10 >= 0.1875 {print}' affy.6.genome > affy.6.related.txt

#Check each related pair of individuals. Create text file, affy.6.related.excl.txt, containing FID
#and IID of each individual to be removed.
plink --bfile affy.6.QC8 --remove affy.6.related.excl.txt --make-bed --out affy.6.QC9


