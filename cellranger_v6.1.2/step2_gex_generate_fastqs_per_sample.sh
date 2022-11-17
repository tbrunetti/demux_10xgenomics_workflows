#!/bin/bash

bamtofastq="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/lib/bin/bamtofastq"
readsPerFastq=260000000 #take bam with highest number of reads and make higher so don't have multiple fastqs per sample
threads=20
outDir="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/scRNA_10x_with_vdj_prime_fastq_files_04092022/step2_outs/"
inputDir="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/scRNA_10x_with_vdj_prime_fastq_files_04092022/gexOut_responders/outs/per_sample_outs/"

cd ${inputDir}
sampleDirsArray=($(ls))

for sample in "${sampleDirsArray[@]}"
do
	echo "Generating fastq from bam for sample ${sample}"
	time ${bamtofastq} --traceback --nthreads="${threads}" --reads-per-fastq="${readsPerFastq}" ${inputDir}"${sample}"/count/sample_alignments.bam ${outDir}"${sample}"
	echo "Finishing fastq generation for ${sample}"
done

