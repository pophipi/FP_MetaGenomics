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


############### Phase #4: BLAST ###############
eval $(grep "^num_threads=" FP_config.cfg)
eval $(grep "^perc_identity=" FP_config.cfg)
eval $(grep "^max_target_seqs=" FP_config.cfg)
eval $(grep "^evalue=" FP_config.cfg)
eval $(grep "^best_hit_score_edge=" FP_config.cfg)
eval $(grep "^best_hit_overhang=" FP_config.cfg)
eval $(grep "^blastn=" FP_config.cfg)
eval $(grep "^blast_database=" FP_config.cfg)
eval $(grep "^WEVOTE=" FP_config.cfg)
eval $(grep "^WEVOTE_DB=" FP_config.cfg)


#for sample in `ls -d *_S14`
for sample in `cat $1`
do

for AnalysisFolder in `ls -d $sample"/assembly/"$sample"_"*`
do
	dir=`basename $AnalysisFolder`
	wevote_wd=$sample"/wevote/"$dir
	mkdir $wevote_wd
        tax_wd=$sample"/taxonomy/"$dir
        mkdir $tax_wd


	$WEVOTE/run_WEVOTE_PIPELINE.sh -i $AnalysisFolder/meta-velvetg.contigs.fa -o $wevote_wd --db $WEVOTE_DB --kraken --clark --blastn --threads 16 -a 0

	$WEVOTE/run_ABUNDANCE.sh -i $wevote_wd"/"$dir"_WEVOTE_Details.txt" -p $tax_wd"/"$dir"_WEVOTE" --db $WEVOTE_DB --seqcount $sample"/assembly/"$dir"/"$dir"_ReadsPerContigSorted.txt"

done



done
