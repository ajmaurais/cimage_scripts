
#clears dir of all sequest, cimage, and .e and .o files

rm -fv ./combined_averaged_ratios.txt
rm -fv ./combined_dta.by_protein.Rout
rm -fv ./combined_dta.html
rm -fv ./combined_dta.png
rm -fv ./combined_dta.txt
rm -fv ./combined_dta.vennDiagram.png
rm -rf ./dta
rm -fv ./cimageOut.txt
rm -fv ./.*~ ./*~ ./*pbs.e[0-9]* ./*pbs.o[0-9]*
rm -fv ./combined_dta.Rout
