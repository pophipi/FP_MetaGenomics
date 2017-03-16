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




############### Phase #3: Assembly ###############

eval $(grep "^kmer=" FP_config.cfg)
eval $(grep "^cov_cutoff=" FP_config.cfg)
eval $(grep "^exp_cov=" FP_config.cfg)
eval $(grep "^min_contig_lgth=" FP_config.cfg)
eval $(grep "^read_trkg=" FP_config.cfg)
eval $(grep "^amos_file=" FP_config.cfg)
eval $(grep "^velvet_path=" FP_config.cfg)
eval $(grep "^metavelvet_path=" FP_config.cfg)
eval $(grep "^kmer_start=" FP_config.cfg)
eval $(grep "^kmer_end=" FP_config.cfg)
eval $(grep "^kmer_interval=" FP_config.cfg)
eval $(grep "^insert_len=" FP_config.cfg)


#for sample in `ls -d *_S14`
for sample in `cat $1`
do

###  Velvet Preprocessing
$velvet_path/velveth $sample/assembly/$sample $kmer_start,$kmer_end,$kmer_interval -fastq -shortPaired -separate $sample/reads.screened.hg19.fastx/left.fq $sample/reads.screened.hg19.fastx/right.fq



### Velvet Assembly
for i in `ls -d $sample"/assembly/"$sample"_"*`
        do

		kmer_dir=`basename $i`
	        $velvet_path/velvetg $i -ins_length $insert_len -cov_cutoff $cov_cutoff -exp_cov $exp_cov -min_contig_lgth $min_contig_lgth -read_trkg $read_trkg -amos_file $amos_file
        	$metavelvet_path/meta-velvetg $i -ins_length $insert_len -min_contig_lgth $min_contig_lgth -amos_file $amos_file | tee logfil

		# Calculate number of reads/Contigs
                unset index
                unset count
                unset contigID
                unset ContigsNumber     

                first=`grep -n -m 1 "{CTG" $i"/meta-velvetg.asm.afg" | sed  's/\([0-9]*\).*/\1/'`
                end=`wc -l $i"/meta-velvetg.asm.afg" | cut -f1 -d " "`
                sed -n "$first","$end"p $i"/meta-velvetg.asm.afg" > $i"/"$kmer_dir"_extractedAssMaps"


                index=-1
                flag=0
                for line in $(cat $i"/"$kmer_dir"_extractedAssMaps")
                do
                        if [ $line == "{CTG" ] #&& [ $flag -eq 0 ]
                        then
                                flag=1
                                index=$((index+1))
                                count[$index]=0
                        fi


                        if [ $line == "{TLE" ] && [ $flag -eq 1 ]
                        then
                                count[$index]=$((count[$index]+1))
                        fi


                        if [[ $line =~ "eid:" ]] && [ $flag -eq 1 ]
                        then
                                contigID[$index]=`echo $line | cut -f2 -d ":" | cut -f1 -d "-"`
                        fi
                done

                ContigsNumber=${#count[@]}
		
		rm $i"/"$kmer_dir"_ReadsPerContig.txt"
		rm $i"/"$kmer_dir"_ReadsPerContigSorted.txt"
		rm $i"/"$kmer_dir"_AssemblyStatistics.txt"		
		rm $i"/"$kmer_dir"_Stat_metavelvet.txt"

                for (( j=0; j < $ContigsNumber ; j++))
                do
                        echo -e ${contigID[$j]} "\t" ${count[$j]} >> $i"/"$kmer_dir"_ReadsPerContig.txt"
                done

                sort -k1,1 $i"/"$kmer_dir"_ReadsPerContig.txt" > $i"/"$kmer_dir"_ReadsPerContigSorted.txt"

                # Calculate Assembly statistics
                ./AssemblyStat.sh $i"/contigs.fa" > $i"/"$kmer_dir"_Stat_velvet.txt"
                ./AssemblyStat.sh $i"/meta-velvetg.contigs.fa" > $i"/"$kmer_dir"_Stat_metavelvet.txt"
done
done
