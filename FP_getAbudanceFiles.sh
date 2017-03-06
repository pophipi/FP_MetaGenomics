#!/bin/bash




#ls -d $sample"/blast/"$sample"_"*

for sample in `ls AbundanceFiles/`
do
	echo "Folder= " $sample
	temp=`ls "AbundanceFiles/"$sample"/"*"VEGAN_Abundance.csv"`
	echo $temp
	cp $temp "AbundanceFiles/"$sample"_WEVOTE_Abundance.csv"
done




#for sample in `cat sample`
#do
#
#	for AnalysisFolder in `ls -d $sample"/taxonomy/"$sample"_"*`
#	do
#		dir=`basename $AnalysisFolder`
#        	wd=$sample"/taxonomy/"$dir	
#		#echo $AnalysisFolder
#		cp -r $wd/ AbundanceFiles/
#	done
#done
