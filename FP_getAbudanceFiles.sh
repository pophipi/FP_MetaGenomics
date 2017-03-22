#!/bin/bash



### Collect files from different samples within multiple runs to one folder
for i in `ls 1*/MK*_S*/taxonomy/*_59/*Abundance*.csv`; do cp $i UCLA_collectedFiles/; done


### Collect Abundance files from different samples within the same run
for sample in `cat sample`
do
	for AnalysisFolder in `ls -d $sample"/taxonomy/"$sample"_"*`
	do
		dir=`basename $AnalysisFolder`
        	wd=$sample"/taxonomy/"$dir	
		#echo $AnalysisFolder
		cp -r $wd/ AbundanceFiles/
	done
done
