plink --bfile infin.3.QC5 --split-x b37 no-fail --make-bed --out infin.3.QC6
#This is step 3 for the preparation of the Infinium 550k v3  array. This section will clean up
#the updated dataset by addressing any sex errors, related individuals and heterozygrous haploid
#loci.

#Requirements
#	Plink 1.90b4
#	Infinium 550k v3 array updated to build GRCh37 (name infin.3.QC5)

#Ensure PAR variants are properly assigned.
plink --bfile infin.3.QC5 --split-x b37 no-fail --make-bed --out infin.3.QC6

#Set remaining .hh instances to missing.
plink --bfile infin.3.QC6 --set-hh-missing --make-bed --out infin.3.QC7

#Return to correct format.
plink --bfile infin.3.QC7 --merge-xplink --bfile infin.3.QC7 --merge-x --make-bed --out infin.3.QC8

#Sex check on pruned dataset.
plink --bfile infin.3.QC8 --indep-pairwise 1000 5 0.2 --out infin.3.QC8
plink --bfile infin.3.QC8 --eplink --bfile infin.3.QC8 --indep-pairwise 1000 5 0.2 --out infin.3.QC8
plink --bfile infin.3.QC8 --extract infin.3.QC8.prune.in --check-sex --out infin.3.sex
grep PROBLEM infin.3.sex.sexcheck >> infin.3.sex.probs.txt

#Remove individuals with sex errors.
plink --bplink --bfile infin.3.QC8 --remove infin.3.sex.probs.txt --make-bed --out infin.3.QC9
file infin.3.QC8 --remove infin.3.sex.probs.txt --make-bed --out infin.3.QC9

