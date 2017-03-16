#!/bin/bash


###******************************************************************###
###********              Metagenomics Pipeline               ********###
###********                                                  ********###
###********       Copyright by Ahmed Metwally (C) 2015       ********###
###********              Finn-Perkins Lab, UIC               ********###
###********  This code is released under GNU GPLv3 License   ********###
###********                                                  ********###
###********       Please report bugs & suggestions to:       ********###
###********                 <ametwa2@uic.edu>                ********###
###********              Vesrion=2.1.0 03/03/2017            ********###
###******************************************************************###


############### Phase #6: Gene Prediction  ###############
eval $(grep "^MetaGMark=" FP_config.cfg)


#for sample in `ls -d *_S14`
for sample in `cat $1`
do

for AnalysisFolder in `ls -d $sample"/assembly/"$sample"_"*`
do
	dir=`basename $AnalysisFolder`
	gene_wd=$sample"/gerepredict/"$dir
	mkdir $wevote_wd




	START=$(date +%s)
                $MetaGMark/mgm/gmhmmp -k -d -a -o $gene_wd/$dir"_PredictedGenes.lst" -m $MetaGMark/mgm/MetaGeneMark_v1.mod $AnalysisFolder/meta-velvetg.contigs.fa
                END=$(date +%s)
                DIFF=`expr $(($END - $START)) / 60`
                #echo -e "\nGene Prediction executed in= "$DIFF" min" >> $AnalysisFolder"_Log.txt"


done



done
