#This is step 3 for the preparation of the Illumina Human 660-Quad array. This section will clean up
#the updated dataset by addressing any sex errors, related individuals and heterozygrous haploid
#loci.

#Requirements
#	Plink 1.90b4
#	Illumina Human 660-Quad array updated to build GRCh37 (name quad.QC4)

#Ensure PAR variants are properly assigned.
plink --bfile quad.QC4 --split-x b37 no-fail --make-bed --out quad.QC5

#Set remaining .hh instances to missing.
plink --bfile quad.QC5 --set-hh-missing --make-bed quad.QC6

#Sex check on pruned dataset.
plink --bfile quad.QC6 --indep-pairwise 1000 5 0.2 --out quad.QC6
plink --bfile quad.QC6 --extract quad.QC6.prune.in --sex-check --out quad.sex
grep PROBLEM quad.sex.sexcheck >> quad.sex.probs.txt

#Remove individuals with sex errors.
plink --brfile quad.QC6 --remove quad.sex.probs.txt --make-bed --out quad.QC7

#Check for related individuals.
plink --bfile quad.QC7 --indep-pairwise 1500 150 0.2 --out quad.QC7
plink --bfile quad.QC7 --extract quad.QC7.prune.in --make-bed --out pruned.quad.QC7
plink --bfile pruned.quad.QC7 --genome --out quad
awk '$10 >= 0.1875 {print}' quad.genome > quad.related.txt

#Check each related pair of individuals. Create text file, quad.related.excl.txt, containing FID
#and IID of each individual to be removed.
plink --bfile quad.QC7 --remove quad.related.excl.txt --make-bed --out quad.QC8


