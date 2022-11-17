#!/bin/bash

#BSUB -q normal # name of queue to use
#BSUB -J demux # job name
#BSUB -P scRNA_CITEseq_vdj_demux
#BSUB -W 10:00 # max walltime of 15 hours
#BSUB -e step2_per_sample_bam_gex_healthy_11152022.err # error file
#BSUB -o step2_per_sample_bam_gex_healthy_11152022.log # stdout file
#BSUB -n 12 # number of CPU cores
#BSUB -R "span[hosts=1]" # span the 5 CPU cores requested above across 1 node
#BSUB -R "rusage[mem=400GB]" # 5BG per core/slot is required
#BSUB -M 200G # kill the job if 5GB is exceeded per core/slot

#!/bin/bash

bamtofastq="/path/to/cellranger-7.0.1/lib/bin/bamtofastq"
readsPerFastq=1000000000000 #take bam with highest number of reads and make higher so don't have multiple fastqs per sample
threads=12
outDir="/path/to/existing/output/directory/for/results/step2_outs/"
inputDir="/path/to/gexOut_dir_name_to_be_created/outs/per_sample_outs/"

cd ${inputDir}
sampleDirsArray=($(ls))

for sample in "${sampleDirsArray[@]}"
do
        echo "Generating fastq from bam for sample ${sample}"
        time ${bamtofastq} --traceback --nthreads="${threads}" --reads-per-fastq="${readsPerFastq}" ${inputDir}"${sample}"/count/sample_alignments.bam ${outDir}"${sample}"
        echo "Finishing fastq generation for ${sample}"
done

