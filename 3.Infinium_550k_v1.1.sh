plink --bfile infin.1.QC5 --split-x b37 no-fail --make-bed --out infin.1.QC6
plink --bfile infin.1.QC6 --set-hh-missing --make-bed infin.1.QC7#This is step 3 for the preparation of the Infinium 550k v1.1  array. This section will clean up
#the updated dataset by addressing any sex errors, related individuals and heterozygrous haploid
#loci.

#Requirements
#	Plink 1.90b4
#	Infinium 550k v1.1 array updated to build GRCh37 (name infin.1.QC5)

#Ensure PAR variants are properly assigned.
plink --bfile infin.1.QC5 --split-x b37 no-fail --make-bed --out infin.1.QC6

#Set remaining .hh instances to missing.
plink --bfile infin.1.QC6 --set-hh-missing --make-bed --out infin.1.QC7

#Set chromosome codes back for compatibility.
plink --bfile infin.1.QC7 --merge-x --make-bed --out infin.1.QC8

#Sex check on pruned dataset.
plink --bfile infin.1.QC8 --indep-pairwise 1000 5 0.2 --out infin.1.QC8
plink --bfile infin.1.QC8 --extract infin.1.QC8.prune.in --check-sex --out infin.1.sex
grep PROBLEM infin.1.sex.sexcheck >> infin.1.sex.probs.txt

#Remove individuals with sex errors.
plink --bfile infin.1.QC8 --remove infin.1.sex.probs.txt --make-bed --out infin.1.QC9

