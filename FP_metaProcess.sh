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




############### Phase #1: Preprocessing ###############

# Extract current directory name and run number
directory=`echo ${PWD##*/}`
Run=$(echo $directory | awk -F _ '{ print $3 }')

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
			mkdir $y/assembly
			#mkdir $y/blast
			mkdir $y/wevote
			mkdir $y/taxonomy
			mkdir $y/genepredict
			echo $y >> sample
			echo $y > "sample_"$y
		fi
		mv $f $y/
	done



### Create samples
#for i in `ls -d *_S*`; do echo $i > "sample_"$i; done




