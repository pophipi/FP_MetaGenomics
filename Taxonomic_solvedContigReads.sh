#!/bin/bash

#PBS -l nodes=1:ppn=16
#PBS -l walltime=10:00:00:00
#PBS -d ./
#PBS -m abe
#PBS -M btn010@uic.edu
#PBS -N pipeline-156-300c-S4_10day_3rd


###******************************************************************###
###********              Metagenomics Pipeline               ********###
###********                                                  ********###
###********       Copyright by Ahmed Metwally (C) 2015       ********###
###********              Finn-Perkins Lab, UIC               ********###
###********  This code is released under GNU GPLv3 License   ********###
###********                                                  ********###
###********       Please report bugs & suggestions to:       ********###
###********                 <ametwa2@uic.edu>                ********###
###******************************************************************###



############### Collecting the Options ###############
# To submit a job, just write the command in the following way:
# qsub -v all=1,b=1,t=1 Taxonomic.sh
# all	=> enables all processes
# p	=> enables preprocessing	
# f     => enables filteration
# a     => enables assembly
# b     => enables blast
# t     => enables taxonomy
# g     => enables geneprediction

preprocessing=0
filter=0
assembly=0
blast=0
taxonomy=0
geneprediction=0


if [ $all -eq 1 ]
then
	preprocessing=1
	filter=1
	assembly=1
	blast=1
	taxonomy=1
	geneprediction=1
fi

if [ $p -eq 1 ]
then
	preprocessing=1
fi

if [ $f -eq 1 ]
then
	filter=1
fi

if [ $a -eq 1 ]
then
	assembly=1
fi

if [ $b -eq 1 ]
then
	blast=1
fi

if [ $t -eq 1 ]
then
	taxonomy=1
fi	
if [ $g -eq 1 ]
then
	geneprediction=1
fi	


# Extract current directory name and run number
directory=`echo ${PWD##*/}`
Run=$(echo $directory | awk -F _ '{ print $3 }')

############### Phase #1: Preprocessing ###############
if [ $preprocessing -eq 1 ]
then
	echo -e "\n\n\n**********     PreProcessing     **********" >> Run_"$Run"_log
	echo -e "\nRun_Identifier:" >> Run_"$Run"_log
        echo $directory >> Run_"$Run"_log

        # Get the date
        echo -e "\nAnalysis_Date:"  >> Run_"$Run"_log
        echo -e `date` >> Run_"$Run"_log
	
	# Get the data info
	echo -e "\nCompressed row samples info:" >> Run_"$Run"_log
	ls *gz | xargs -n 1 wc -c | awk '{print $2"\tSize="int($1/1000000)"MB"}' >> Run_"$Run"_log

	
	START=$(date +%s)
	ls *gz | parallel gunzip
	END=$(date +%s)
	DIFF=`expr $(($END - $START)) / 60`
	echo -e "\nSamples decompression executed in= "$DIFF" min" >> Run_"$Run"_log
	echo -e "\nDecompressed row samples info:" >> Run_"$Run"_log

        ls *fastq | xargs -n 1 wc -c -l -L| awk '{print $4"\tSize="int($2/1000000)"MB""\tNumberReads="$1/4"\tLongestReadSize="$3}' >> Run_"$Run"_log

	for f in *.fastq
	do
			if [[ $f =~ R1 ]]
			then
					x=`echo $f | sed s/_L001_R1_001/.1/`
					mv $f $x
			fi

			if [[ $f =~ R2 ]]
			then
					x=`echo $f | sed s/_L001_R2_001/.2/`
					mv $f $x
			fi  
	done

	for f in *.fastq
	do
		mv $f ${f%.fastq}.fq
	done

	if [ -f sample ]
	then 
		rm sample
	fi

	for f in *.fq
	do
		y=`echo $f | sed s/.[12].fq//`
		if [ ! -d "$y" ]; then
			mkdir $y
			mkdir $y/blast
			mkdir $y/assembly
			mkdir $y/taxonomy
			mkdir $y/genepredict
			echo $y >> sample
		fi
		mv $f $y/
	done
fi




############### Phase #2: Filteration ###############
if [ $filter -eq 1 ]
then
	echo -e "\n\n\n**********     Filteration     **********" >> Run_"$Run"_log
        echo -e "\nRun_Identifier:" >> Run_"$Run"_log
        echo $directory >> Run_"$Run"_log
        echo -e "\nAnalysis_Date:"  >> Run_"$Run"_log
        echo -e `date` >> Run_"$Run"_log

	# Call MOCAT for read trimming, screening, filteration

	#       Trim and filter the reads
	START=$(date +%s)
	echo -e "\nRead Trimming command: \n MOCAT.pl -sf sample -rtf" >> Run_"$Run"_log
	MOCAT.pl -sf sample -rtf
	
	END=$(date +%s)
        DIFF=`expr $(($END - $START)) / 60`
        echo -e "\nRead Trimming executed in= "$DIFF" min" >> Run_"$Run"_log



	#       screen the trimmed reads against hg19
	START=$(date +%s)
	echo -e "\nremove hg contamination command: \n MOCAT.pl -sf sample -s hg19" >> Run_"$Run"_log
	MOCAT.pl -sf sample -s hg19

	END=$(date +%s)
        DIFF=`expr $(($END - $START)) / 60`
        echo -e "\nData screening executed in= "$DIFF" min" >> Run_"$Run"_log

	#       Filter for paired end. This step is important only for the filtering 
	#       the paired end after screening. It is necessary to run the next profiling step
	START=$(date +%s)
	echo -e "\nFilteration command: \n MOCAT.pl -sf sample -f hg19" >> Run_"$Run"_log
	MOCAT.pl -sf sample -f hg19
	END=$(date +%s)
        DIFF=`expr $(($END - $START)) / 60`
        echo -e "\nData filteration executed in= "$DIFF" min" >> Run_"$Run"_log





	#       Calculate the base and read (insert) coverages
	START=$(date +%s)
	echo -e "\nCalculate base and read coverage command: \n MOCAT.pl -sf sample -p hg19" >> Run_"$Run"_log
	MOCAT.pl -sf sample -p hg19
	END=$(date +%s)
	DIFF=`expr $(($END - $START)) / 60`
        echo -e "\nBase count executed in= "$DIFF" min" >> Run_"$Run"_log
	echo -e "\nHQ data info:" >> Run_"$Run"_log
	
	for AnalysisFolder in `cat sample`
        do
		ls $AnalysisFolder/reads.processed.fastx/*gz | xargs -n 1 wc -c | awk '{print $2"\tSize="int($1/1000000)"MB"}' >> Run_"$Run"_log
		echo -e "\n"
	done
	echo -e "\nUnmapped data to hg data info:" >> Run_"$Run"_log

        for AnalysisFolder in `cat sample`
        do
                ls $AnalysisFolder/reads.screened.hg19.fastx/*gz | xargs -n 1 wc -c | awk '{print $2"\tSize="int($1/1000000)"MB"}' >> Run_"$Run"_log
                echo -e "\n"
        done
	echo -e "\nMapped data to hg data info:" >> Run_"$Run"_log
        
	for AnalysisFolder in `cat sample`
        do
                ls $AnalysisFolder/reads.extracted.hg19.fastx/*gz | xargs -n 1 wc -c | awk '{print $2"\tSize="int($1/1000000)"MB"}' >> Run_"$Run"_log
                echo -e "\n"
        done

	for AnalysisFolder in `cat sample`
	do
		gunzip $AnalysisFolder/reads.screened.hg19.fastx/*pair*gz

                #  change the screened files named to be compatible with the velvet
              	mv $AnalysisFolder/reads.screened.hg19.fastx/*pair.1.fq $AnalysisFolder/reads.screened.hg19.fastx/left.fq
                mv $AnalysisFolder/reads.screened.hg19.fastx/*pair.2.fq $AnalysisFolder/reads.screened.hg19.fastx/right.fq
	done
fi



############### Phase #3: Assembly ###############
if [ $assembly -eq 1 ]
then
	eval $(grep "^kmer=" Pipeline.cfg)
	eval $(grep "^cov_cutoff=" Pipeline.cfg)
	eval $(grep "^exp_cov=" Pipeline.cfg)
	eval $(grep "^min_contig_lgth=" Pipeline.cfg)
	eval $(grep "^read_trkg=" Pipeline.cfg)
	eval $(grep "amos_file=" Pipeline.cfg)

	for AnalysisFolder in `cat sample` 
	do 
		
		echo -e "\n\n\n**********     Assembly     **********" >> $AnalysisFolder"_Log.txt"
        	echo -e "\nRun_Identifier:" >> $AnalysisFolder"_Log.txt"
        	echo $directory >> $AnalysisFolder"_Log.txt"
        	echo -e "\nAnalysis_Date:"  >> $AnalysisFolder"_Log.txt"
        	echo -e `date` >> $AnalysisFolder"_Log.txt"

		
		START=$(date +%s)
		echo -e "\nBuilding index for velvelt command: \n/export/home/clustperkinsdlab/tools/velvet_1.2.10/velveth $AnalysisFolder/assembly $kmer -fastq -shortPaired -separate $AnalysisFolder/reads.screened.hg19.fastx/left.fq $AnalysisFolder/reads.screened.hg19.fastx/right.fq" >> $AnalysisFolder"_Log.txt"
		echo -e "\n/export/home/clustperkinsdlab/tools/velvet_1.2.10/velvetg $AnalysisFolder/assembly -cov_cutoff $cov_cutoff -exp_cov $exp_cov -min_contig_lgth $min_contig_lgth -read_trkg $read_trkg -amos_file $amos_file" >> $AnalysisFolder"_Log.txt"
		echo -e "\n/export/home/clustperkinsdlab/tools/MetaVelvet/meta-velvetg $AnalysisFolder/assembly -exp_cov $exp_cov -min_contig_lgth $min_contig_lgth | tee $AnalysisFolder/assembly/logfile" >> $AnalysisFolder"_Log.txt"
		
		
		/export/home/clustperkinsdlab/tools/velvet_1.2.10/velveth $AnalysisFolder/assembly $kmer -fastq -shortPaired -separate $AnalysisFolder/reads.screened.hg19.fastx/left.fq $AnalysisFolder/reads.screened.hg19.fastx/right.fq
                /export/home/clustperkinsdlab/tools/velvet_1.2.10/velvetg $AnalysisFolder/assembly -cov_cutoff $cov_cutoff -exp_cov $exp_cov -min_contig_lgth $min_contig_lgth -read_trkg $read_trkg -amos_file $amos_file
		/export/home/clustperkinsdlab/tools/MetaVelvet/meta-velvetg $AnalysisFolder/assembly -exp_cov $exp_cov -min_contig_lgth $min_contig_lgth | tee $AnalysisFolder/assembly/logfile
	



		# Calculate number of reads/Contigs
		unset index
		unset count
		unset contigID
		unset ContigsNumber	

		first=`grep -n -m 1 "{CTG" $AnalysisFolder/assembly/velvet_asm.afg | sed  's/\([0-9]*\).*/\1/'`
                end=`wc -l $AnalysisFolder/assembly/velvet_asm.afg | cut -f1 -d " "`
                sed -n "$first","$end"p $AnalysisFolder/assembly/velvet_asm.afg > $AnalysisFolder/assembly/extractedInfo2
		






		index=-1
		flag=0
		for line in $(cat $AnalysisFolder/assembly/extractedInfo2) 
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

		for (( i=0; i < $ContigsNumber ; i++))
		do
			echo -e ${contigID[$i]} "\t" ${count[$i]} >> $AnalysisFolder/assembly/ReadsPerContig.txt
		done

		sort -k1,1 $AnalysisFolder/assembly/ReadsPerContig.txt > $AnalysisFolder/assembly/ReadsPerContigSorted.txt 

	

		# Calculate Assembly statistics
                ./AssemblyStat.sh $AnalysisFolder/assembly/contigs.fa > $AnalysisFolder/assembly/AssemblyStatistics.txt
		./AssemblyStat.sh $AnalysisFolder/assembly/meta-velvetg.contigs.fa > $AnalysisFolder/assembly/Stat_metavelvet.txt

		END=$(date +%s)		
		DIFF=`expr $(($END - $START)) / 60`
        	echo -e "\nAssembly executed in= "$DIFF" min" >> $AnalysisFolder"_Log.txt"

		# Get (conting_ID, length, coverage) for all assembeled contigs
		cat $AnalysisFolder/assembly/stats.txt | cut -f 1,2,6 > $AnalysisFolder/assembly/All_contings_stats.txt
		rm $AnalysisFolder/assembly/stats.txt
	
		# get the (conting_ID, length, coverage) that satisfy length,cov condition
		grep '^>' $AnalysisFolder/assembly/contigs.fa | awk -F "_" '{print $2"\t"$4"\t"$6}' > $AnalysisFolder/assembly/HQ_contigs_stats.txt
		
		# Get the contigs info                
		wc -c -l $AnalysisFolder/assembly/HQ_contigs_stats.txt | awk '{print "Contig info:\t"$3"\tNumberContigs="$1}' >> $AnalysisFolder"_Log.txt"		

		# Contigs N50
		echo -e "\nContigs N50=" >> $AnalysisFolder"_Log.txt"
		cut -f 2 $AnalysisFolder/assembly/HQ_contigs_stats.txt | sort -n | awk '{len[i++]=$1;sum+=$1} END {for (j=0;j<i+1;j++) {csum+=len[j]; if (csum>sum/2) {print len[j];break}}}' >> $AnalysisFolder"_Log.txt"

		# Contigs length Statistics
		awk     'NR==1  {max=0;min=300000000}
         NR>1   {sum+=$2
                 if (min>$2) min=$2
                 if (max<$2) max=$2
                 cnt = NR
                }
         END    {print  "\nContigs Length Statistics:\navg="sum/(cnt-1)"\tmin="min"\tmax="max}
        ' $AnalysisFolder/assembly/HQ_contigs_stats.txt >> $AnalysisFolder"_Log.txt"

		# Contigs coverage Statistics
		awk     'NR==1  {max=0;min=300000000}
         NR>1   {sum+=$3
                 if (min>$3) min=$3
                 if (max<$3) max=$3
                 cnt = NR
                }
         END    {print  "\nContigs coverage Statistics:\navg="sum/(cnt-1)"\tmin="min"\tmax="max}
        ' $AnalysisFolder/assembly/HQ_contigs_stats.txt >> $AnalysisFolder"_Log.txt"
	done
fi


############### Phase #4: Blast ###############
if [ $blast -eq 1 ]
then
	eval $(grep "^num_threads=" Pipeline.cfg)
	eval $(grep "^perc_identity=" Pipeline.cfg)
	eval $(grep "^max_target_seqs=" Pipeline.cfg)
	eval $(grep "^evalue=" Pipeline.cfg)
	eval $(grep "^best_hit_score_edge=" Pipeline.cfg)
	eval $(grep "^best_hit_overhang=" Pipeline.cfg)
	eval $(grep "^blastn=" Pipeline.cfg)
	eval $(grep "^ref_database=" Pipeline.cfg)

	for AnalysisFolder in `cat sample`
	do
		echo -e "\n\n\n**********     Blast     **********" >> $AnalysisFolder"_Log.txt"
        	echo -e "\nRun_Identifier:" >> $AnalysisFolder"_Log.txt"
        	echo $directory >> $AnalysisFolder"_Log.txt"

        	# Get the date
        	echo -e "\nAnalysis_Date:"  >> $AnalysisFolder"_Log.txt"
        	echo -e `date` >> $AnalysisFolder"_Log.txt"

		START=$(date +%s)
		
		echo -e "\nBlast command: \n /export/home/clustperkinsdlab/tools/ncbi-blast/bin/blastn -db /export/home/clustperkinsdlab/Databases/nt/nt -query $AnalysisFolder/assembly/contigs.fa -out $AnalysisFolder/blast/blastOutput.blast -outfmt "6 qseqid sseqid sgi staxids length qstart qend sstart send pident evalue score bitscore stitle" -num_threads $num_threads -perc_identity $perc_identity -max_target_seqs $max_target_seqs -evalue $evalue -best_hit_score_edge $best_hit_score_edge -best_hit_overhang $best_hit_overhang" >> $AnalysisFolder"_Log.txt"

#		/export/home/clustperkinsdlab/tools/ncbi-blast/bin/blastn -db /export/home/clustperkinsdlab/Databases/nt/nt -query $AnalysisFolder/assembly/contigs.fa -out $AnalysisFolder/blast/blastOutput.blast -outfmt "6 qseqid sseqid sgi staxids length qstart qend sstart send pident evalue score bitscore stitle" -num_threads $num_threads -perc_identity $perc_identity -max_target_seqs $max_target_seqs -evalue $evalue -best_hit_score_edge $best_hit_score_edge -best_hit_overhang $best_hit_overhang
	

		$blastn -db $ref_database -query $AnalysisFolder/assembly/contigs.fa -out $AnalysisFolder/blast/blastOutput.blast -outfmt "6 qseqid sseqid sgi staxids length qstart qend sstart send pident evalue score bitscore stitle" -num_threads $num_threads -perc_identity $perc_identity -max_target_seqs $max_target_seqs -evalue $evalue -best_hit_score_edge $best_hit_score_edge -best_hit_overhang $best_hit_overhang

		sort -k1,1 -u $AnalysisFolder/blast/blastOutput.blast > $AnalysisFolder/blast/temp
		mv $AnalysisFolder/blast/temp $AnalysisFolder/blast/blastOutput.blast
		END=$(date +%s)
		DIFF=`expr $(($END - $START)) / 60`
                echo -e "\nBlast executed in= "$DIFF" min" >> $AnalysisFolder"_Log.txt"
	done
fi




############### Phase #5: Taxonomy ###############
if [ $taxonomy -eq 1 ]
then	
	
	eval $(grep "^taxonomy_names=" Pipeline.cfg)
        eval $(grep "^taxonomy_nodes=" Pipeline.cfg)


	for AnalysisFolder in `cat sample`
	do
		echo -e "\n\n\n**********     Taxonomy     **********" >> $AnalysisFolder"_Log.txt"
        	echo -e "\nRun_Identifier:" >> $AnalysisFolder"_Log.txt"
        	echo $directory >> $AnalysisFolder"_Log.txt"

        	# Get the date
        	echo -e "\nAnalysis_Date:"  >> $AnalysisFolder"_Log.txt"
        	echo -e `date` >> $AnalysisFolder"_Log.txt"
		
		START=$(date +%s)

		# Taxonomy for reads 
		cut -f1,4 $AnalysisFolder/blast/blastOutput.blast | awk -F '[_\t]' '{print $2 "\t" $NF}' | sort -k1,1 > $AnalysisFolder/taxonomy/$AnalysisFolder"_Contig_Tax.txt"
		join $AnalysisFolder/taxonomy/$AnalysisFolder"_Contig_Tax.txt" $AnalysisFolder/assembly/ReadsPerContigSorted.txt | cut -f2,3 -d " " | sed "s/ /,/g" > $AnalysisFolder/taxonomy/$AnalysisFolder"_Tax_Reads.csv"



		#cut -f4 $AnalysisFolder/blast/blastOutput.blast > $AnalysisFolder/taxonomy/taxIDs.txt
		#sed 's/$/,1/' $AnalysisFolder/taxonomy/taxIDs.txt > $AnalysisFolder/taxonomy/temp.txt
		awk -F, '{a[$1]+=$2;}END{for(i in a)print i", "a[i];}' $AnalysisFolder/taxonomy/$AnalysisFolder"_Tax_Reads.csv" > $AnalysisFolder/taxonomy/temp.csv

		# Remove white space
		sed -r 's/\s+//g' $AnalysisFolder/taxonomy/temp.csv > $AnalysisFolder/taxonomy/$AnalysisFolder"_MEGAN.csv"
		rm $AnalysisFolder/taxonomy/temp.*

		#NAMES="/export/home/clustperkinsdlab/Databases/TaxDB/names.dmp"
		#NODES="/export/home/clustperkinsdlab/Databases/TaxDB/nodes.dmp"
		NAMES=$taxonomy_names
		NODES=$taxonomy_nodes

		# Obtain the name corresponding to a taxid or the taxid of the parent taxa
		#get_name_or_taxid()
		#{
		#		grep --max-count=1 "^${1}"$'\t' "${2}" | cut --fields="${3}"
		#}

		get_name()
                {
                                grep --max-count=1 "^${1}"$'\t' "${2}" | cut --fields="${3}"
                                #grep --max-count=1 "^${1}"$'\t' "${2}"
                }

                get_rank()
                {
                                grep --max-count=1 "^${1}"$'\t' "${2}" | cut --fields="${3}"
                                #grep --max-count=1 "^${1}"$'\t' "${2}"
                }


                get_taxid()
                {
                                grep --max-count=1 "^${1}"$'\t' "${2}" | cut --fields="${3}"
                                #grep --max-count=1 "^${1}"$'\t' "${2}"
                }
		
		for line in $(cat $AnalysisFolder/taxonomy/$AnalysisFolder"_MEGAN.csv") 
		do 	
			TAXID=`echo $line | cut -d "," -f 1`
			FirstTaxID=$TAXID
			TAXONOMY=",,,,,,,"
                        # Loop until you reach the root of the taxonomy (i.e. taxid = 1)
                        while [[ "${TAXID}" -gt 1 ]]
                        do
                                # Obtain the scientific name corresponding to a taxid
                                NAME=$(get_name "${TAXID}" "${NAMES}" "3")
                                NAME=`echo $NAME | sed "s/ /_/g"`

                                RANK=$(get_rank "${TAXID}" "${NODES}" "5")
                                echo $RANK
                                echo $NAME
                                if [ $RANK == "species" ];
                                then
                                        TAXONOMY=`echo $TAXONOMY | awk -F, '{$8="'$NAME'";}1' OFS=,`;
                                        echo $TAXONOMY 
                                elif [ $RANK == "genus" ];
                                then
                                        TAXONOMY=`echo $TAXONOMY | awk -F, '{$7="'$NAME'";}1' OFS=,` ;
                                        echo $TAXONOMY
                                elif [ $RANK == "family" ];
                                then
                                        TAXONOMY=`echo $TAXONOMY | awk -F, '{$6="'$NAME'";}1' OFS=,` ;
                                        echo $TAXONOMY
                                elif [ $RANK == "order" ];
                                then
                                        TAXONOMY=`echo $TAXONOMY | awk -F, '{$5="'$NAME'";}1' OFS=,` ;

                                elif [ $RANK == "class" ];
                                then
                                        TAXONOMY=`echo $TAXONOMY | awk -F, '{$4="'$NAME'";}1' OFS=,` ;
                                elif [ $RANK == "phylum" ];
                                then
                                        TAXONOMY=`echo $TAXONOMY | awk -F, '{$3="'$NAME'";}1' OFS=,` ;
                                elif [ $RANK == "kingdom" ];
                                then
                                        TAXONOMY=`echo $TAXONOMY | awk -F, '{$2="'$NAME'";}1' OFS=,` ;

                                elif [ $RANK == "superkingdom" ];
                                then
                                        TAXONOMY=`echo $TAXONOMY | awk -F, '{$1="'$NAME'";}1' OFS=,` ;

                                fi


                                # Obtain the parent taxa taxid
                                PARENT=$(get_taxid "${TAXID}" "${NODES}" "3")
                                # Build the taxonomy path
                               # TAXONOMY="${NAME},${TAXONOMY}"
                                TAXID="${PARENT}"
                        done
                        echo -e $line","$TAXONOMY >> $AnalysisFolder/taxonomy/$AnalysisFolder"_Complete_Tax_with_counts.csv"
                done

		
		 #cut -f1,2 -d "," $AnalysisFolder/taxonomy/$AnalysisFolder"_Complete_Tax_with_counts.csv" > $AnalysisFolder/taxonomy/$AnalysisFolder"_MEGAN.csv"
		
		END=$(date +%s)
		DIFF=`expr $(($END - $START)) / 60`
                echo -e "\nTaxonomy executed in= "$DIFF" min" >> $AnalysisFolder"_Log.txt"
	done
fi




############### Phase #6: Gene Prediction using MetaGeneMark ###############
if [ $geneprediction -eq 1 ]
then
	for AnalysisFolder in `cat sample`
	do

		echo -e "\n\n\n**********     Gene Prediction     **********" >> $AnalysisFolder"_Log.txt"
        	echo -e "\nRun_Identifier:" >> $AnalysisFolder"_Log.txt"
        	echo $directory >> $AnalysisFolder"_Log.txt"
        	echo -e "\nAnalysis_Date:"  >> $AnalysisFolder"_Log.txt"
        	echo -e `date` >> $AnalysisFolder"_Log.txt"
		
		START=$(date +%s)
		
		echo -e "\nGene Prediction command: \n /export/home/clustperkinsdlab/tools/MetaGeneMark_linux_64/mgm/gmhmmp -k -d -o $AnalysisFolder/genepredict/$AnalysisFolder"_PredictedGenes.lst" -m /export/home/clustperkinsdlab/tools/MetaGeneMark_linux_64/mgm/MetaGeneMark_v1.mod $AnalysisFolder/assembly/contigs.fa" >> $AnalysisFolder"_Log.txt"

		/export/home/clustperkinsdlab/tools/MetaGeneMark_linux_64/mgm/gmhmmp -k -d -a -o $AnalysisFolder/genepredict/$AnalysisFolder"_PredictedGenes.lst" -m /export/home/clustperkinsdlab/tools/MetaGeneMark_linux_64/mgm/MetaGeneMark_v1.mod $AnalysisFolder/assembly/contigs.fa
		END=$(date +%s)
		DIFF=`expr $(($END - $START)) / 60`
                echo -e "\nGene Prediction executed in= "$DIFF" min" >> $AnalysisFolder"_Log.txt"
	done
fi
