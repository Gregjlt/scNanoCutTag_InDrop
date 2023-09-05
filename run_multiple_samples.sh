#!/bin/bash
sample_sheet=$1

get_mem () {
local READ1=$1
file_size_kb=$(du -Lk "$READ1" | cut -f1 | sed 's/[a-zA-Z]*//g' | sed 's/\..*//g')


if [ $file_size_kb == "" ]
then
file_size_kb=0
fi

if [ $file_size_kb -le 1000000 ]
then
mem=34
elif [ $file_size_kb -le 5000000 ]
then
mem=40
elif [  $file_size_kb -le 10000000 ]
then
mem=60
elif [ $file_size_kb -le 15000000 ]
then
mem=80
elif [  $file_size_kb -le 20000000 ]
then
mem=100
elif [ $file_size_kb -le 25000000 ]
then
mem=120
else 
mem=120
fi
echo "$mem"

}


########################################################
#############     HUMAN IP K27 CURIE      ##################
########################################################


#CREATE CONFIG FILE : HUMAN, BEADS CURIE, IP, BED = 20k +50k
cd /data/users/gjouault/GitLab/scNanoCutTag_InDrop

while IFS= read -r line
do
  BCL_DIR=$(echo "$line" | cut -d',' -f1)
  NGS_NAME=$(echo "$line" | cut -d',' -f2)
  ASSEMBLY=$(echo "$line" | cut -d',' -f3)
  NANOBC=$(echo "$line" | cut -d',' -f4)
  MARK=$(echo "$line" | cut -d',' -f5)
  DESIGN_TYPE=LBC
  
  echo $BCL_DIR
  echo $NGS_NAME
  echo $ASSEMBLY
  echo $NANOBC
  echo $MARK 
  echo $DESIGN_TYPE
  
  FINAL_NAME=${NGS_NAME}_${ASSEMBLY}_${NANOBC}_${MARK}
  
  echo $FINAL_NAME 
  
  OUTPUT_CONFIG=/data/tmp/gjouault/results/CONFIG_scNanoCutTag_InDrop_${FINAL_NAME}
 
  ./schip_processing.sh GetConf --template  CONFIG_TEMPLATE --configFile species_design_configs.csv --designType ${DESIGN_TYPE} --genomeAssembly ${ASSEMBLY} --outputConfig ${OUTPUT_CONFIG} 
  # --mark ${MARK}
 
  OUTPUT_DIR=/data/kdi_prod/project_result/1184/02.00/results/scCutTag/${ASSEMBLY}/${FINAL_NAME}

  READ_1=${BCL_DIR}/${NGS_NAME}.R1.fastq.gz
  READ_2=${BCL_DIR}/${NGS_NAME}.R2.fastq.gz
  READ_3=${BCL_DIR}/${NGS_NAME}.R3.fastq.gz
  
  echo
  
mem_to_use=$(get_mem $READ_1)
ppn_to_use=$((mem_to_use // 6))

echo "cd /data/users/gjouault/GitLab/scCutTag_InDrop;./schip_processing.sh All --forward ${READ_1} --reverse ${READ_3} --index ${READ_2} --conf ${OUTPUT_CONFIG} --output ${OUTPUT_DIR} --name ${FINAL_NAME} --nanobc ${NANOBC}"| qsub -l nodes=1:ppn=${ppn_to_use},mem=${mem_to_use}gb,walltime=164:00:00 -N job_${FINAL_NAME}


done < "$sample_sheet"


