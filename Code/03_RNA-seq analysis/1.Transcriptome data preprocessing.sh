#!/bin/bash
#JSUB -q normal
#JSUB -n 10
#JSUB -e %J
#JSUB -o %J
#JSUB -J qc
source activate rnaseq

keywords=("")

for keyword in "${keywords[@]}"
do

    mkdir ./"$keyword"/clean
    mkdir ./"$keyword"/bam
    mkdir ./"$keyword"/tmp
    
    fastp -w 5 -i ./"$keyword"/"$keyword"_R1.fq.gz -o ./"$keyword"/clean/"$keyword"_R1_clean.fq.gz -I ./"$keyword"/"$keyword"_R2.fq.gz -O ./"$keyword"/clean/"$keyword"_R2_clean.fq.gz -j ./"$keyword"/clean/"$keyword".json -h ./"$keyword"/clean/"$keyword".html
    hisat2 --dta -p 2 -x /storage/public/home/rengang/001liu/project/sun/genome/ncbi-cow-ARS-UI_Ramb_v2.0_chrID/hisat2_ssjchipseq/ARS-UCD2.0 -1 ./"$keyword"/clean/"$keyword"_R1_clean.fq.gz -2 ./"$keyword"/clean/"$keyword"_R2_clean.fq.gz -S ./"$keyword"/bam/"$keyword".sam > ./"$keyword"/bam/"$keyword"_hisat2.log 2>&1
    samtools view -@ 2 -bSh -q 0 ./"$keyword"/bam/"$keyword".sam -o ./"$keyword"/bam/"$keyword".bam
    samtools sort -@ 2 ./"$keyword"/bam/"$keyword".bam > ./"$keyword"/bam/"$keyword"_sort.bam
    samtools index ./"$keyword"/bam/"$keyword"_sort.bam -o ./"$keyword"/bam/"$keyword"_sort.bam.bai
    stringtie ./"$keyword"/bam/"$keyword"_sort.bam -e -B -p 2 -G /storage/public/home/rengang/001liu/project/sun/genome/ncbi-cow-refseq-gtf_chrID/GCF_002263795.3_ARS-UCD2.0_genomic.gff -o ./"$keyword"/"$keyword"/"$keyword".gtf
    rm -f ./"$keyword"/bam/"$keyword".sam
    rm -f ./"$keyword"/bam/"$keyword".bam
done