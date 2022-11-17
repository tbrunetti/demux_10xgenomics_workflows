#!/bin/bash

# must be repeated for each multiplexed full set independently

samtools="samtools"
inputDir="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/scRNA_10x_with_vdj_prime_fastq_files_04092022/step2_outs/"
txnRef="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/refdata-gex-GRCh38-2020-A/"
vdjRef="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/vdj_IMGT_human/"
perSampleMetricsBaseDir="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/scRNA_10x_with_vdj_prime_fastq_files_04092022/gexOut_responders/outs/per_sample_outs/" 
featureType="VDJ-T"
originalFastq="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/scRNA_10x_with_vdj_prime_fastq_files_04092022/gex_r/"
originalFastqBase="1_Responder_GEX"
cellranger="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/bin/cellranger"
outDir="/home/tonya/software/cellranger-6.1.2_5prime_HTO_VDJ_pipeline/scRNA_10x_with_vdj_prime_fastq_files_04092022/step3_outs/"

cd ${perSampleMetricsBaseDir}
samples=($(ls)) # gets all the sample name diretories in the inputDir

for sample in "${samples[@]}";
do
	cd $sample	
	expectedCells=$(grep "Cells assigned to this sample" "${perSampleMetricsBaseDir}""${sample}"/metrics_summary.csv | cut -f6 -d"," | cut -f1 -d" ")
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
			echo "expect-cells,${expectedCells}" >> "${outDir}"${sample}_multi.csv
			echo "r1-length,26" >> "${outDir}"${sample}_multi.csv
			echo "chemistry,SC5P-R2" >> "${outDir}"${sample}_multi.csv
			echo "include-introns,true" >> "${outDir}"${sample}_multi.csv
			echo -e "\n" >> "${outDir}"${sample}_multi.csv
			echo "[vdj]" >> "${outDir}"${sample}_multi.csv
			echo "reference,${vdjRef}" >> "${outDir}"${sample}_multi.csv
			echo -e "\n" >> "${outDir}"${sample}_multi.csv
			echo "[libraries]" >> "${outDir}"${sample}_multi.csv
			echo "fastq_id,fastqs,feature_types" >> "${outDir}"${sample}_multi.csv
			gexDir=$(ls -1 ${inputDir}${sample} | grep "0_1") 
			echo ${gexDir}
			echo "bamtofastq,${inputDir}${sample}/${gexDir},gene expression" >> "${outDir}"${sample}_multi.csv
			echo "${originalFastqBase},${originalFastq},${featureType}" >> "${outDir}"${sample}_multi.csv
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
				echo "expect-cells,${expectedCells}" >> "${outDir}"${sample}_multi.csv
				echo "r1-length,26" >> "${outDir}"${sample}_multi.csv
				echo "chemistry,SC5P-R2" >> "${outDir}"${sample}_multi.csv
				echo "include-introns,true" >> "${outDir}"${sample}_multi.csv
				echo -e "\n" >> "${outDir}"${sample}_multi.csv
				echo "[vdj]" >> "${outDir}"${sample}_multi.csv
				echo "reference,${vdjRef}" >> "${outDir}"${sample}_multi.csv
				echo -e "\n" >> "${outDir}"${sample}_multi.csv
				echo "[libraries]" >> "${outDir}"${sample}_multi.csv
				echo "fastq_id,fastqs,feature_types" >> "${outDir}"${sample}_multi.csv
				gexDir=$(ls -1 ${inputDir}${sample} | grep "1_1")
				echo "bamtofastq,${inputDir}${sample}/${gexDir},gene expression" >> "${outDir}"${sample}_multi.csv
				echo "${originalFastqBase},${originalFastq},${featureType}" >> "${outDir}"${sample}_multi.csv
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
