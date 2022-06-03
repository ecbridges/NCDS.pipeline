#This is the second step for the Affymetrix 500k array preparation.
#This step updates the genome build to GRCh37. In order to do this, follow the instructions at
https://www.well.ox.ac.uk/~wrayner/strand/ for the update_build.pl script.
#For the Affymetrix 500k array, the SNP identifiers were updated from SNP_A IDs to  rsIDs (see above webpage for files) before updating the build:

plink --bfile affy.500.QC4 --update-ids affy.500.ids.txt --make-bed --out affy.500.QC5 
# A custom update file was used. See link for information.
#The file should be uploaded from affy.500.QC5 to GRCh37.
# Name the new, updated file affy.500.QC6
