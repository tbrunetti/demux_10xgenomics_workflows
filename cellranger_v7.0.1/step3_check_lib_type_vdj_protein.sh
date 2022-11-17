#!/bin/bash

# must be repeated for each multiplexed full set independently
#BSUB -q normal # name of queue to use
#BSUB -J demux # job name
#BSUB -P scRNA_CITEseq_vdj_demux
#BSUB -W 12:00 # max walltime of 15 hours
#BSUB -e step3_demux_gex_vdj_antibody_healthy_11152022.err # error file
#BSUB -o step3_demux_gex_vdj_antibody_healthy_11152022.log # stdout file
#BSUB -n 12 # number of CPU cores
#BSUB -R "span[hosts=1]" # span the 5 CPU cores requested above across 1 node
#BSUB -R "rusage[mem=200GB]" # 5BG per core/slot is required
#BSUB -M 200G # kill the job if 5GB is exceeded per core/slot

module load samtools/1.8

samtools="/path/to/samtools"
inputDir="/path/to/step2_outs/"
txnRef="/path/to/cellranger-7.0.1/refdata-gex-GRCh38-2020-A/"
vdjRef="/path/to/cellranger-7.0.1/Homo_sapien_vdj_IMGT/vdj_IMGT_human/"
featureCsv="/path/to/feature_barcodes_for_antibody_capture_citeseq.csv"
perSampleMetricsBaseDir="/path/to/gexOut_dir_name_to_be_created/gexOut_healthy/outs/per_sample_outs/" 
featureTypeVDJ="VDJ-B"
featureTypeCITE="Antibody Capture"
originalFastq="/path/to/all/original/fastq/files/"
originalFastqBaseGEX="Fastq_Name_Prefix_for_File_Containing_GEX_Reads"
originalFastqBaseFB="Fastq_Name_Prefix_for_File_Containing_Antibody_FeatureBardoe_Reads,"
originalFastqBaseVDJ="Fastq_Name_Prefix_for_File_Containing_VDJ_Reads"
cellranger="/path/to/cellranger-7.0.1/cellranger"
outDir="/path/to/existing/diretory/to/store/results/step3_outs/"

cd ${perSampleMetricsBaseDir}
samples=($(ls)) # gets all the sample name diretories in the inputDir

for sample in "${samples[@]}";
do
	cd $sample	
	expectedCells=$(grep "Cells assigned to this sample" "${perSampleMetricsBaseDir}""${sample}"/metrics_summary.csv | cut -f6- -d"," | cut -f1 -d" " | sed 's/,//g' | sed 's/\"//g')
	samtools view -H count/sample_alignments.bam | grep "^@CO.*library_info.*library_id\":0"
	# checks if gene expressoin library is associated with 0 id
	isGex=$(samtools view -H count/sample_alignments.bam | grep "^@CO.*library_info.*library_id\":0" | grep "Gene Expression" | wc -l)
	if [[ "${isGex}" -eq 1 ]]
	then
		echo "${sample} gex library ID is 0, checking mux ID..."
		# since gex is library id 0, check if mux is library id 1
		isMux=$(samtools view -H count/sample_alignments.bam | grep "^@CO.*library_info.*library_id\":1" | grep "Multiplexing Capture" | wc -l)
		if [[ "${isMux}" -eq 1 ]]
		then
			echo "${sample} mux library ID is 1, ready to start demultiplexing"
			# run demux
			# generate sample sheet
			echo "[gene-expression]" > "${outDir}"${sample}_multi.csv
			echo "reference,${txnRef}" >> "${outDir}"${sample}_multi.csv
			echo "force-cells,${expectedCells}" >> "${outDir}"${sample}_multi.csv
			echo "r1-length,26" >> "${outDir}"${sample}_multi.csv
			echo "chemistry,SC5P-R2" >> "${outDir}"${sample}_multi.csv
			echo "include-introns,true" >> "${outDir}"${sample}_multi.csv
			echo "check-library-compatibility,false" >> "${outDir}"${sample}_multi.csv
			echo -e "\n" >> "${outDir}"${sample}_multi.csv
			echo "[vdj]" >> "${outDir}"${sample}_multi.csv
			echo "reference,${vdjRef}" >> "${outDir}"${sample}_multi.csv
			echo -e "\n" >> "${outDir}"${sample}_multi.csv
			echo "[feature]" >> "${outDir}"${sample}_multi.csv
			echo "reference,${featureCsv}" >> "${outDir}"${sample}_multi.csv
			echo -e "\n" >> "${outDir}"${sample}_multi.csv
			echo "[libraries]" >> "${outDir}"${sample}_multi.csv
			echo "fastq_id,fastqs,feature_types" >> "${outDir}"${sample}_multi.csv
			fastqDirs=($(ls -1 ${inputDir}${sample} | grep "0_1"))
			for gexDir in "${fastqDirs[@]}";
			do
				echo ${gexDir}  
				echo "bamtofastq,${inputDir}${sample}/${gexDir},gene expression" >> "${outDir}"${sample}_multi.csv
			done
			echo "${originalFastqBaseVDJ},${originalFastq},${featureTypeVDJ}" >> "${outDir}"${sample}_multi.csv
			echo "${originalFastqBaseFB},${originalFastq},${featureTypeCITE}" >> "${outDir}"${sample}_multi.csv
			cd ${outDir}
			time $cellranger multi --id=step3_out_${sample} --csv=${sample}_multi.csv --disable-ui
		else
			echo "There is an error with ${sample} library checks.  Please use samtools view -H to determine how samples were split"
			exit 1
		fi
	else
		echo
		isGex=$(samtools view -H count/sample_alignments.bam | grep "^@CO.*library_info.*library_id\":1" | grep "Gene Expression" | wc -l)
		if [[ "${isGex}" -eq 1 ]]
		then
			echo "${sample} gex library ID is 1, checking mux ID..."
			# since gex is library id 0, check if mux is library id 0
			isMux=$(samtools view -H count/sample_alignments.bam | grep "^@CO.*library_info.*library_id\":1" | grep "Multiplexing Capture" | wc -l)
			if [[ "${isMux}" -eq 1 ]]
			then
				echo "${sample} mux library ID is 0, ready to start demultiplexing"
				# run demux
				# generate sample sheet
				echo "[gene-expression]" > "${outDir}"${sample}_multi.csv
				echo "reference,${txnRef}" >> "${outDir}"${sample}_multi.csv
				echo "force-cells,${expectedCells}" >> "${outDir}"${sample}_multi.csv
				echo "r1-length,26" >> "${outDir}"${sample}_multi.csv
				echo "chemistry,SC5P-R2" >> "${outDir}"${sample}_multi.csv
				echo "include-introns,true" >> "${outDir}"${sample}_multi.csv
				echo "check-library-compatibility,false" >> "${outDir}"${sample}_multi.csv
				echo -e "\n" >> "${outDir}"${sample}_multi.csv
				echo "[vdj]" >> "${outDir}"${sample}_multi.csv
				echo "reference,${vdjRef}" >> "${outDir}"${sample}_multi.csv
				echo -e "\n" >> "${outDir}"${sample}_multi.csv
				echo "[feature]" >> "${outDir}"${sample}_multi.csv
				echo "reference,${featureCsv}" >> "${outDir}"${sample}_multi.csv
				echo -e "\n" >> "${outDir}"${sample}_multi.csv
				echo "[libraries]" >> "${outDir}"${sample}_multi.csv
				echo "fastq_id,fastqs,feature_types" >> "${outDir}"${sample}_multi.csv
				fastqDirs=$(ls -1 ${inputDir}${sample} | grep "1_1")
                        	for gexDir in "${fastqDirs[@]}";
                        	do
                                	echo ${gexDir}  
                                	echo "bamtofastq,${inputDir}${sample}/${gexDir},gene expression" >> "${outDir}"${sample}_multi.csv
                        	done
				echo "${originalFastqBaseVDJ},${originalFastq},${featureTypeVDJ}" >> "${outDir}"${sample}_multi.csv
				echo "${originalFastqBaseFB},${originalFastq},${featureTypeCITE}" >> "${outDir}"${sample}_multi.csv
				cd ${outDir}
				time $cellranger multi --id=step3_out_${sample} --csv=${sample}_multi.csv --disable-ui
			else
                        	echo "There is an error with ${sample} library checks.  Please use samtools view -H to determine how samples were split"
                        	exit 1
			fi
		fi
	fi
	cd "${perSampleMetricsBaseDir}"
done
