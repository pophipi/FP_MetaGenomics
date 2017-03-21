#!/bin/bash

#PBS -l nodes=1:ppn=16
#PBS -l walltime=1:00:00:00
#PBS -d ./
#PBS -m abe
#PBS -M ametwa2@uic.edu
#PBS -N $sample


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


############### Collecting the Options ###############
# To submit a job, just write the command in the following way:
# qsub -v sample=...... FP_run.sh

#sample=$1
#./FP_metaFilter.sh $sample
#./FP_metaAssembly.sh $sample
./FP_metaWEVOTE.sh $sample
#./FP_metaGenes.sh $sample
