
############### Phase #2: Filteration ###############
# Extract current directory name and run number
directory=`echo ${PWD##*/}`
Run=$(echo $directory | awk -F _ '{ print $3 }')
echo -e "\n\n\n**********     Filteration     **********" >> Run_"$Run"_log
echo -e "\nRun_Identifier:" >> Run_"$Run"_log
echo $directory >> Run_"$Run"_log
echo -e "\nAnalysis_Date:"  >> Run_"$Run"_log
echo -e `date` >> Run_"$Run"_log

#all MOCAT for read trimming, screening, filteration


sample=$1

#      Trim and filter the reads
START=$(date +%s)
echo -e "\nRead Trimming command: \n MOCAT.pl -sf sample -rtf" >> Run_"$Run"_log
MOCAT.pl -sf $sample -rtf
	
END=$(date +%s)
DIFF=`expr $(($END - $START)) / 60`
echo -e "\nRead Trimming executed in= "$DIFF" min" >> Run_"$Run"_log


#       screen the trimmed reads against hg19
START=$(date +%s)
echo -e "\nremove hg contamination command: \n MOCAT.pl -sf sample -s hg19" >> Run_"$Run"_log
MOCAT.pl -sf $sample -s hg19

END=$(date +%s)
DIFF=`expr $(($END - $START)) / 60`
echo -e "\nData screening executed in= "$DIFF" min" >> Run_"$Run"_log

#       Filter for paired end. This step is important only for the filtering 
#       the paired end after screening. It is necessary to run the next profiling step
START=$(date +%s)
echo -e "\nFilteration command: \n MOCAT.pl -sf sample -f hg19" >> Run_"$Run"_log
$MOCAT.pl -sf $sample -f hg19
END=$(date +%s)
DIFF=`expr $(($END - $START)) / 60`
echo -e "\nData filteration executed in= "$DIFF" min" >> Run_"$Run"_log


#      Calculate the base and read (insert) coverages
START=$(date +%s)
echo -e "\nCalculate base and read coverage command: \n MOCAT.pl -sf sample -p hg19" >> Run_"$Run"_log
#MOCAT.pl -sf $sample -p hg19
END=$(date +%s)
DIFF=`expr $(($END - $START)) / 60`
echo -e "\nBase count executed in= "$DIFF" min" >> Run_"$Run"_log
echo -e "\nHQ data info:" >> Run_"$Run"_log



for AnalysisFolder in `cat $sample`
        do
		ls $AnalysisFolder/reads.processed.fastx/*gz | xargs -n 1 wc -c | awk '{print $2"\tSize="int($1/1000000)"MB"}' >> Run_"$Run"_log
		echo -e "\n"
	done
	echo -e "\nUnmapped data to hg data info:" >> Run_"$Run"_log

        for AnalysisFolder in `cat $sample`
        do
                ls $AnalysisFolder/reads.screened.hg19.fastx/*gz | xargs -n 1 wc -c | awk '{print $2"\tSize="int($1/1000000)"MB"}' >> Run_"$Run"_log
                echo -e "\n"
        done
	echo -e "\nMapped data to hg data info:" >> Run_"$Run"_log
        
	for AnalysisFolder in `cat $sample`
        do
                ls $AnalysisFolder/reads.extracted.hg19.fastx/*gz | xargs -n 1 wc -c | awk '{print $2"\tSize="int($1/1000000)"MB"}' >> Run_"$Run"_log
                echo -e "\n"
        done

	for AnalysisFolder in `cat $sample`
	do
		gunzip $AnalysisFolder/reads.screened.hg19.fastx/*pair*gz

                #  change the screened files named to be compatible with the velvet
              	mv $AnalysisFolder/reads.screened.hg19.fastx/*pair.1.fq $AnalysisFolder/reads.screened.hg19.fastx/left.fq
                mv $AnalysisFolder/reads.screened.hg19.fastx/*pair.2.fq $AnalysisFolder/reads.screened.hg19.fastx/right.fq
	done
