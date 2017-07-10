## FP-Metagenomics-Pipeline ##

This analysis pipeline is primarily designed to analyze data coming from Illumina MiSeq Sequencing machine. Nevertheless, with a few changes, it can be adapted to any sequencing platforms.

The Pipeline isn't yet fully commented and finished!

# Getting Started
This section details steps for installing and running the FP-Metagenomics-Pipeline for use on the UIC Extreme cluster. Current the FP-Metagenomics-Pipeline version only supports Linux. If you experience difficulty installing or running the software, please contact (Ahmed Metwally: ametwa2@uic.edu).

### Prerequisites
* Active user account on UIC Extreme
* Installed and configured Linux on VirtualBox according to WEVOTE Installation tutorial
* Basic knowledge of Linux navigation from WEVOTE tutorial

## Installing, Testing, and Running

#### Clone the project to your local repository:
Obtain copy of pipeline package file from Ahmed or Kai. If you've already done this, you should have a folder called FP_meta_PACKAGE in your home directory on Extreme. To check, login to Extreme from a terminal in VirtualBox and type the following commands from the home directory:
```
ls *PACKAGE
```

You should see a list of the contents of any folder with the suffix PACKAGE in your home directory. Including:
```
FP_meta_PACKAGE:
FP_MetaGenomics  MetaGeneMark_linux_64  MetaVelvet  MOCAT  ncbi-blast  nt  velvet_1.2.10  WEVOTE  WEVOTE_DB
```

#### Add FP-Metagenomics-Pipeline path to the PATH environmental variable
Since we will always place the pipeline PACKAGE in your home directory, you can add the pipeline's executable programs to the system PATH and PERL5LIB environment variables with the following:
```
export PATH=$PATH:~/FP_meta_PACKAGE/FP_MetaGenomics:~/FP_meta_PACKAGE/MOCAT/src
export PERL5LIB=$PERL5LIB:~/Documents/FP_meta_PACKAGE/MOCAT/src
```

To make these changes permanent, you need to add the lines of code above to your ~/.profile file using vim. Then load the .profile file:
```
cd
vim .profile
<add lines to .profile, save and quit>
source ~/.profile
```
_NOTE: Recall that you can use the following command to open files for editing:
```
vim <file path>
```
Once in vim, press "i" to enter insert mode and you will be able to edit text. Exit insert mode by pressing escape when editing is completed. Then type ":wq" to save and quit the file._

#### Copy MOCAT.cfg and FP_config.cfg to the folder containing your sample files. Copy wevote.cfg here as well if you do not already have a preconfigured wevote.cfg. If you do, copy that file instead.

For first time users, it is highly recommended that you keep an original copy of your raw FASTQ sample files and do processing on a seperate copy in a seperate folder. All of the configuration files (except wevote.cfg if you already have WEVOTE installed) can be found in the FP_MetaGenomics folder of the FP_meta_PACKAGE.
```
cd ~/FP_meta_PACKAGE/FP_MetaGenomics
cp MOCAT.cfg <directory-where-sample-file-exists>
cp FP_config.cfg <directory-where-sample-file-exists>
cp wevote.cfg <directory-where-sample-file-exists>
cd <directory-where-sample-file-exists>
```

#### In the directory where your sample files are placed, edit the .cfg files copied from FP-Metagenomics-Pipeline:
For MOCAT.cfg edit the following line with your own netid:
```
MOCAT_dir                : /export/home/<your-net-id>/FP_meta_PACKAGE/MOCAT/
```

If your data is not in paired FASTQ format, you may need to change other settings in this configuration file for the pipeline to function.

For FP_config.cfg edit the following lines:
```
velvet_path="/export/home/<your-net-id>/FP_meta_PACKAGE/velvet_1.2.10/"
metavelvet_path="/export/home/<your-net-id>/FP_meta_PACKAGE/MetaVelvet/"
...
blastn="/export/home/<your-net-id>FP_meta_PACKAGE/ncbi-blast/ncbi-blast/bin/blastn"
blast_database="/export/home/<your-net-id>/FP_meta_PACKAGE/nt/nt"
...
WEVOTE="/export/home/<your-net-id>/WEVOTE_PACKAGE/WEVOTE"
WEVOTE_DB="/export/home/<your-net-id>/WEVOTE_PACKAGE/WEVOTE_DB"
...
MetaGMark="/export/home/<your-net-id>/FP_meta_PACKAGE/MetaGeneMark_linux_64/"
```

For wevote.cfg edit the following lines if they have not been set already:
```
blastnPath="/export/home/<your-net-id>/WEVOTE_PACKAGE/blast"
blastDB="/export/home/<your-net-id>/WEVOTE_PACKAGE/blastDB/nt"
krakenPath="/export/home/<your-net-id>/WEVOTE_PACKAGE/kraken"
krakenDB="/export/home/<your-net-id>/WEVOTE_PACKAGE/krakenDB"
clarkPath="/export/home/<your-net-id>/WEVOTE_PACKAGE/clark"
clarkDB="/export/home/<your-net-id>/WEVOTE_PACKAGE/clarkDB"
metaphlanPath="/export/home/<your-net-id>/WEVOTE_PACKAGE/metaphlan"
```

## Running the FP-Metagenomics-Pipeline
Currently, running the FP Pipeline requires two seperate steps. First, you will run the processing script on all available samples then the rest of the pipeline scripts. You will need to comment out the parts of the script that you do not want to run. 

Running processing only: Comment out everything except FP_metaprocess.sh. First, open FP_run.sh.
```
cd ~/FP_meta_PACKAGE/FP_MetaGenomics
vim FP_run.sh
```

Check that all lines in FP_run.sh starting with "FP" except FP_metaProcess.sh are commented out (have a # in front)
```
FP_metaProcess.sh
#FP_metaFilter.sh $sample
#FP_metaAssembly.sh $sample
#FP_metaWEVOTE.sh $sample
#FP_metaGenes.sh $sample
```

Save and quit from the vim editor. cd to the folder containing your compressed .fastq.gz files (each sample should be paired with a R1 and R2 file.
```
cd <location of your fastq files>
```

Run the processing pipeline script.
```
qsub FP_run.sh
```

After successful processing, your sample folder should now contain individual folders named for each paired sample processed. These folders contain the required inputs for the rest of the pipeline. Now you can uncomment the other pipeline steps in FP_run.sh.
```
cd ~/FP_meta_PACKAGE/FP_MetaGenomics
vim FP_run.sh
```

Edit the file so the lines starting wtih "F" except FP_metaProcess.sh are NOT commented out.
```
#FP_metaProcess.sh
FP_metaFilter.sh $sample
FP_metaAssembly.sh $sample
FP_metaWEVOTE.sh $sample
FP_metaGenes.sh $sample
```

Save and quit. Change directories back to the directory containing your samples.
```
cd <location of processed fastq samples>
```

To submit a job, just write the command in the following way:
```
qsub -v sample=<name of sample you would like to run> FP_run.sh
```

To run all the steps after processing within the run's directory:
```
for i in `ls sample_*`; do qsub -v sample=$i FP_run.sh; done
```

#### Example:
```
???
```

#### Output Format?

