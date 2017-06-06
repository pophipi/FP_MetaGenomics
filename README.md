## FP-Metagenomics-Pipeline ##

This analysis pipeline is primarily designed to analyze data coming from Illumina MiSeq Sequencing machine. Nevertheless, with a few changes, it can be adapted to any sequencing platforms.

The Pipeline isn't yet fully commented and finished!

# Getting Started
This section details steps for installing and running the FP-Metagenomics-Pipeline. Current the FP-Metagenomics-Pipeline version only supports Linux. If you experience difficulty installing or running the software, please contact (Ahmed Metwally: ametwa2@uic.edu).

### Prerequisites
* BLASTN, Kraken, and Clark installed on the machine.
* WEVOTE installed and configured on the machine.
* OpenMP for multithreading
* At least 75GB RAM for running Kraken and Clark. You may ignore this prerequisite if you choose not to use Kraken or Clark
* R: for generating summary statistics, graphs, and messaging the data to be compatible with Phyloseq package.
* MetaGMark for gene prediction from FP_Meta_Update
* MOCAT isntalled
* MetaVelvet and Velvet installed

## Installing, Testing, and Running

#### Clone the project to your local repository:
```
git clone https://github.com/aametwally/FP_MetaGenomics.git
```

#### Add FP-Metagenomics-Pipeline path to the PATH environmental variable
```
export PATH=$PATH:<path-to-FP_MetaGenomics>
```

Alternatively, you can add the "path-to-FP_MetaGenomics" to the PATH enviornmental variable in your ~/.profile file. 

#### Copy??? MOCAT.cfg and FP_config.cfg to the folder containing your sample files. Copy wevote.cfg here as well if you do not already have a preconfigured wevote.cfg. If you do, copy that file instead.

```
cp MOCAT.cfg [directory-where-sample-file-exists]
cp FP_config.cfg [directory-where-sample-file-exists]
cp wevote.cfg [directory-where-sample-file-exists]
cd [directory-where-sample-file-exists]
```
#### In the directory where your sample files are placed, edit the .cfg files copied from FP-Metagenomics-Pipeline:

For MOCAT.cfg edit the following lines???:
```
MOCAT_dir                : /mnt/store2/home/ametwa2/MOCAT/
MOCAT_data_type          : fastx [fastx,solexaqa]
```

For FP_config.cfg edit the following lines???:
```
velvet_path="/mnt/store2/home/ametwa2/FP_meta_update/FP_meta_PACKAGE/velvet_1.2.10/"
metavelvet_path="/mnt/store2/home/ametwa2/FP_meta_update/FP_meta_PACKAGE/MetaVelvet/"
...
blastn="/mnt/store2/home/ametwa2/FP_meta_update/FP_meta_PACKAGE/ncbi-blast/ncbi-blast/bin/blastn"
blast_database="/mnt/store2/home/ametwa2/FP_meta_update/FP_meta_PACKAGE/nt/nt"
...
WEVOTE="/export/home/ametwa2/WEVOTE_update/WEVOTE_PACKAGE/WEVOTE"
WEVOTE_DB="/export/home/ametwa2/WEVOTE_update/WEVOTE_PACKAGE/WEVOTE_DB"
...
MetaGMark="/mnt/store2/home/ametwa2/FP_meta_update/FP_meta_PACKAGE/MetaGeneMark_linux_64/"
```

For wevote.cfg edit the following lines if they have not been set already:
```
blastnPath="/export/home/ametwa2/WEVOTE_update/WEVOTE_PACKAGE/blast"
blastDB="/export/home/ametwa2/WEVOTE_update/WEVOTE_PACKAGE/blastDB/nt"
krakenPath="/export/home/ametwa2/WEVOTE_update/WEVOTE_PACKAGE/kraken"
krakenDB="/export/home/ametwa2/WEVOTE_update/WEVOTE_PACKAGE/krakenDB"
clarkPath="/export/home/ametwa2/WEVOTE_update/WEVOTE_PACKAGE/clark"
clarkDB="/export/home/ametwa2/WEVOTE_update/WEVOTE_PACKAGE/clarkDB"
metaphlanPath="/export/home/ametwa2/WEVOTE_update/WEVOTE_PACKAGE/metaphlan"
```

## Running the FP-Metagenomics-Pipeline
To submit a job, just write the command in the following way:
```
qsub -v sample=...... FP_run.sh
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

