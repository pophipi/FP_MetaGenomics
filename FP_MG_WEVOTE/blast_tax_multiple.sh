#!/bin/bash

#PBS -l nodes=1:ppn=16
#PBS -l walltime=1:00:00:00
#PBS -d ./
#PBS -m abe
#PBS -M ametwa2@uic.edu
#PBS -N a_b_profile_S14

#sample=$1

#### This is how to call this script:
#qsub -v sample="MKAN003341_S1" blast_tax_multiple.sh



#echo $1
for sample in `ls -d *_S16`
#for sample in `ls -d *_S14`
#for sample in `cat sample`
do



##### Assembly:
#eval $(grep "^kmer=" Pipeline.cfg)
#        eval $(grep "^cov_cutoff=" Pipeline.cfg)
#        eval $(grep "^exp_cov=" Pipeline.cfg)
#        eval $(grep "^min_contig_lgth=" Pipeline.cfg)
#        eval $(grep "^read_trkg=" Pipeline.cfg)
#        eval $(grep "amos_file=" Pipeline.cfg)
#
#/export/home/clustperkinsdlab/tools/velvet_1.2.10/velveth $sample/assembly/$sample 51,101,10 -fastq -shortPaired -separate $sample/reads.screened.hg19.fastx/left.fq $sample/reads.screened.hg19.fastx/right.fq
#
#
#
#
#for i in `ls -d $sample"/assembly/"$sample"_"*`
#        do
#        /export/home/clustperkinsdlab/tools/velvet_1.2.10/velvetg $i -ins_length 500 -cov_cutoff $cov_cutoff -exp_cov $exp_cov -min_contig_lgth $min_contig_lgth -read_trkg $read_trkg -amos_file $amos_file
#        /export/home/clustperkinsdlab/tools/MetaVelvet/meta-velvetg $i -ins_length 500 -min_contig_lgth $min_contig_lgth -amos_file $amos_file | tee logfil
#
#
#
#		# Calculate number of reads/Contigs
#                unset index
#                unset count
#                unset contigID
#                unset ContigsNumber     
#
#                first=`grep -n -m 1 "{CTG" $i"/meta-velvetg.asm.afg" | sed  's/\([0-9]*\).*/\1/'`
#                end=`wc -l $i"/meta-velvetg.asm.afg" | cut -f1 -d " "`
#                sed -n "$first","$end"p $i"/meta-velvetg.asm.afg" > $i"/extractedInfo2"
#
#
#
#
#                index=-1
#                flag=0
#                for line in $(cat $i"/extractedInfo2")
#                do
#                        if [ $line == "{CTG" ] #&& [ $flag -eq 0 ]
#                        then
#                                flag=1
#                                index=$((index+1))
#                                count[$index]=0
#                        fi
#
#
#                        if [ $line == "{TLE" ] && [ $flag -eq 1 ]
#                        then
#                                count[$index]=$((count[$index]+1))
#                        fi
#
#
#                        if [[ $line =~ "eid:" ]] && [ $flag -eq 1 ]
#                        then
#                                contigID[$index]=`echo $line | cut -f2 -d ":" | cut -f1 -d "-"`
#                        fi
#                done
#
#                ContigsNumber=${#count[@]}
#		
#
#		rm $i"/ReadsPerContig.txt"
#		rm $i"/ReadsPerContigSorted.txt"
#		rm $i"/AssemblyStatistics.txt"		
#		rm $i"/Stat_metavelvet.txt"
#
#                for (( j=0; j < $ContigsNumber ; j++))
#                do
#                        echo -e ${contigID[$j]} "\t" ${count[$j]} >> $i"/ReadsPerContig.txt"
#                done
#
#                sort -k1,1 $i"/ReadsPerContig.txt" > $i"/ReadsPerContigSorted.txt"
#
#
#
#                # Calculate Assembly statistics
#                ./AssemblyStat.sh $i"/contigs.fa" > $i"/Stat_velvet.txt"
#                ./AssemblyStat.sh $i"/meta-velvetg.contigs.fa" > $i"/Stat_metavelvet.txt"
#done
#
#
#
#
#
#
#### Blast
#eval $(grep "^num_threads=" Pipeline.cfg)
#        eval $(grep "^perc_identity=" Pipeline.cfg)
#        eval $(grep "^max_target_seqs=" Pipeline.cfg)
#        eval $(grep "^evalue=" Pipeline.cfg)
#        eval $(grep "^best_hit_score_edge=" Pipeline.cfg)
#        eval $(grep "^best_hit_overhang=" Pipeline.cfg)
#        eval $(grep "^blastn=" Pipeline.cfg)
#        eval $(grep "^ref_database=" Pipeline.cfg)
#
#
#for AnalysisFolder in `ls -d $sample"/assembly/"$sample"_"*`
# do
#	ass_dir=`basename $AnalysisFolder`
#	mkdir $sample"/blast/"$ass_dir
#
#$blastn -db $ref_database -query $AnalysisFolder/meta-velvetg.contigs.fa -out $sample"/blast/"$ass_dir"/"$ass_dir"_blastOutput.blast" -outfmt "6 qseqid sseqid sgi staxids length qstart qend sstart send pident evalue score bitscore stitle" -num_threads $num_threads -perc_identity $perc_identity -max_target_seqs $max_target_seqs -evalue $evalue -best_hit_score_edge $best_hit_score_edge -best_hit_overhang $best_hit_overhang
#
#	sort -k1,1 -u $sample"/blast/"$ass_dir"/"$ass_dir"_blastOutput.blast" > $sample"/blast/"$ass_dir"/"$ass_dir"_blastOutput_Filtered.blast"
#done



for AnalysisFolder in `ls -d $sample"/blast/"$sample"_"*`
do
        dir=`basename $AnalysisFolder`
        wd=$sample"/taxonomy/"$dir
        #mkdir $wd

#        cut -f1,4 $AnalysisFolder/$dir"_blastOutput_Filtered.blast" | awk -F '[_\t]' '{print $2 "\t" $NF}' | sort -k1,1 > $wd/$sample"_contigID_tax.txt"
#        join $wd/$sample"_contigID_tax.txt"  $sample"/assembly/"$dir"/ReadsPerContigSorted.txt" | sed "s/ /\t/g" > $wd/$sample"_contigID_Tax_ReadCount.txt"
#        cut -f1 $AnalysisFolder/$dir"_blastOutput_Filtered.blast" | awk -F '[_\t]' '{print $2 "\t" $0}' | sort -k1,1 > $wd/$sample"_contigID_contigheader.txt"
#        join $wd/$sample"_contigID_contigheader.txt" $wd/$sample"_contigID_Tax_ReadCount.txt" | cut -f2,3,4 -d " " | sed "s/ /,/g" > $wd/$sample"_contigheader_Tax_readCount.csv"
        #/export/home/clustperkinsdlab/tools/WEVOTE_CONTIGS/ABUNDANCE_CONTIGS -i $wd/$sample"_contigheader_Tax_readCount.csv" -p $wd/$sample -d /export/home/clustperkinsdlab/Databases/WEVOTE_DB/

	/export/home/clustperkinsdlab/tools/WEVOTE_CONTIGS_VEGAN/ABUNDANCE_CONTIGS_VEGAN -i $wd/$sample"_contigheader_Tax_readCount.csv" -p $wd/$sample"_VEGAN" -d /export/home/clustperkinsdlab/Databases/WEVOTE_DB/


done

done
