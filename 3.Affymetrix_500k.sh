#This is step 3 for the preparation of the Infinium 500k array. This section will clean up
#the updated dataset by addressing any sex errors, related individuals and heterozygrous haploid
#loci.

#Requirements
#	Plink 1.90b4
#	Infinium 550k v3 array updated to build GRCh37 (name affy.500.QC5)

#Ensure PAR variants are properly assigned.
plink --bfile affy.500.QC5 --split-x b37 no-fail --make-bed --out affy.500.QC6

#Set remaining .hh instances to missing.
plink --bfile affy.500.QC6 --set-hh-missing --make-bed affy.500.QC7
