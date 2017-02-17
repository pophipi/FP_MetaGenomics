#!/bin/bash

#PBS -l nodes=1:ppn=16
#PBS -l walltime=20:00:00
#PBS -d ./
#PBS -m abe
#PBS -M ametwa2@uic.edu
#PBS -N 163



for sample in `ls -d MK*_S*`
do

for AnalysisFolder in `ls -d $sample"/taxonomy/"$sample"_67"`
do
#        dir=`basename $AnalysisFolder`
#        wd=$sample"/taxonomy/"$dir

        /export/home/clustperkinsdlab/tools/WEVOTE_CONTIGS_VEGAN/ABUNDANCE_CONTIGS_VEGAN -i $AnalysisFolder/$sample"_contigheader_Tax_readCount.csv" -p $AnalysisFolder/$sample"_VEGAN" -d /export/home/clustperkinsdlab/Databases/WEVOTE_DB/

done


done
