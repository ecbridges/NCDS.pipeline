#This is the second step for the Affymetrix v6 array preparation.
#This step updates the genome build to GRCh37. In order to do this, follow the instructions at
https://www.well.ox.ac.uk/~wrayner/strand/ for the update_build.pl script.
#For the Affymetrix v6 array, a custom matchesd file is needed. Information available at the webpage above.
#This array must be updated twice. The custom file should be used to update the build twice - first update to
#GRCh36, then update the GRCh36 file to GRCh37.
# Name the new, updated file affy.6.QC4

#Variant IDs should then be updated from SNP_A to rs.
plink --bfile affy.6.QC4 --update-name variant.update.txt --make-bed --out affy.6.QC5
