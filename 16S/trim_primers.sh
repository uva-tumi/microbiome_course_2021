#!/bin/bash

path_to_cutadapt=/Users/mac9jc/Library/Python/3.8/bin/cutadapt
path_to_bbmap=/Users/mac9jc/Documents/bbmap
path_for_logs=/Users/mac9jc/Documents/work/TUMI/microbiome_course_2021/16S/results/logfiles
path_for_input_data=/Users/mac9jc/Documents/work/TUMI/microbiome_course_2021/16S/data/sequence_data
path_for_output_data=/Users/mac9jc/Documents/work/TUMI/microbiome_course_2021/16S/data/sequence_data/trimmed

files=$path_for_input_data/Mouse*.fastq.txt
for f in $files; do
    echo '_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _'
    echo $f
    if [[ $f == *_R1_* ]]
    then
        echo 'trimming'
        pre_string=$path_for_input_data/
        
        file_without_ext="${f%.*}"
        file_without_ext="${file_without_ext%.*}"
        echo $f
        f_without_path=$(basename $f)
        f_string=$(echo $(basename $file_without_ext)| cut -d'R' -f 1)
        f_without_num=${f_string%"R1_001"}
        f_rev=$f_without_num"R2_001.fastq.txt"
        f_rev=$pre_string$f_rev
        Echo $f_rev
        log=$path_for_logs/$f_without_num"_primer_trim.log"

        ## Adapter trimming # always recommended prior to merging
        output_file1=$path_for_output_data/$f_without_num"1_Adapter_trimmed.fq"
        output_file2=$path_for_output_data/$f_without_num"2_Adapter_trimmed.fq"
        $path_to_bbmap/bbduk.sh in1=$f in2=$f_rev out1=$output_file1 out2=$output_file2 ref=$path_to_bbmap/resources/adapters.fa ktrim=r k=23 mink=11 hdist=1 tpe tbo


        ## primer trimming
        output_file3=$path_for_output_data/$f_without_num"1_PT.fq.gz"
        output_file4=$path_for_output_data/$f_without_num"2_PT.fq.gz"
        output_file5=$path_for_output_data/$f_without_num"1_PT2.fq.gz"
        output_file6=$path_for_output_data/$f_without_num"2_PT2.fq.gz"
        $path_to_cutadapt -a GTGCCAGCAGCCGCGGTAA...ATTAGATACCCTGGTAGTCC -A GGACTACCAGGGTATCTAAT...TTACCGCGGCTGCTGGCAC -o $output_file3 -p $output_file4 $output_file1 $output_file2 --cores=4 > $path_for_logs/"cutadapt_log_"$f_without_num".txt"
        $path_to_cutadapt -a GGACTACCAGGGTATCTAAT...TTACCGCGGCTGCTGGCAC -A GTGCCAGCAGCCGCGGTAA...ATTAGATACCCTGGTAGTCC --minimum-length 50 -o $output_file5 -p $output_file6 $output_file3 $output_file4 --cores=4 > $path_for_logs/"cutadapt_log2_"$f_without_num".txt"

    fi
done