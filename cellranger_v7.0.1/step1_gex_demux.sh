#!/bin/bash

#BSUB -q normal # name of queue to use
#BSUB -J demux # job name
#BSUB -P scRNA_CITEseq_vdj_demux
#BSUB -W 48:00 # max walltime of 15 hours
#BSUB -e step1_demux_gex_healthy_11142022.err # error file
#BSUB -o step1_demux_gex_healthy_11142022.log # stdout file
#BSUB -n 12 # number of CPU cores
#BSUB -R "span[hosts=1]" # span the 5 CPU cores requested above across 1 node
#BSUB -R "rusage[mem=400GB]" # 5BG per core/slot is required
#BSUB -M 200G # kill the job if 5GB is exceeded per core/slot

cellranger="/path/to/cellranger-7.0.1/cellranger"
id="gexOut_dir_name_to_be_created"
inputcsv="/path/to/input_csv_cellranger_multi_example.csv"

${cellranger} multi --id=${id} --csv=${inputcsv} --disable-ui
