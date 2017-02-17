#!/bin/bash

#PBS -l nodes=1:ppn=16
#PBS -l walltime=3:00:00:00
#PBS -A ametwa2
#PBS -d ./
#PBS -M ametwa2@uic.edu


rm -r logs abundance.tables
rm MOCAT.cutoff5prime_calculated MOCAT.executed MOCAT.successful

for AnalysisFolder in `cat sample`
do
	rm $AnalysisFolder/assembly/Graph2 $AnalysisFolder/assembly/LastGraph $AnalysisFolder/assembly/PreGraph $AnalysisFolder/assembly/Roadmaps $AnalysisFolder/assembly/Sequences
	rm -r $AnalysisFolder/reads.* $AnalysisFolder/base.coverage* $AnalysisFolder/insert.coverage* $AnalysisFolder/temp

	

done



