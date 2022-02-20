#!/usr/bin/env bash

USER=tuv
ENV_NAME=qiime2-snakemake-2019.7

#set some variables based on the config file
CFG_FILE=config.yml
CFG_CONTENT=$(cat $CFG_FILE | sed -r 's/\ //g' | sed -r 's/:/=/g' | sed -r 's/.*=$//g' | sed -r 's/#.*$//g' | sed -r 's/"//g')
eval "$CFG_CONTENT"

echo ${project_dir}
PRJ=$(echo ${project_dir} | sed -r 's/.*\///g')
QIIME_DENOISE=denoise_fwd_${trim_left_f}-${trunc_len_f}_rev_${trim_left_r}-${trunc_len_r}

SAVE_DIR=/mnt/isilon/microbiome/analysis/${USER}/QIIME2/${PRJ}
SCRIPTS_DIR=processing_scripts
DATA_DIR=Data
RAW_DATA_DIR=Data_raw
META_DIR=metadata

source ~/.bashrc.conda #needed to make "conda" command to work
conda activate ${ENV_NAME} #get the environment packacges and versions
pip freeze > ${project_dir}/${PRJ}_requirements.txt
conda env export > ${project_dir}/${PRJ}_environment.yml

if [ ! -d ${SAVE_DIR}/${SCRIPTS_DIR} ]; then
  mkdir -p ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${project_dir}/${PRJ}_requirements.txt ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${project_dir}/${PRJ}_environment.yml ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${project_dir}/cluster.json ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${project_dir}/config.yml ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${project_dir}/run_snakemake.bash ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${project_dir}/Snakefile ${SAVE_DIR}/${SCRIPTS_DIR}
  cp -r ${project_dir}/rules/ ${SAVE_DIR}/${SCRIPTS_DIR}
  cp -r ${project_dir}/scripts/ ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${classifier_fp} ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${unassigner_species_fp} ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${rscript} ${SAVE_DIR}/${SCRIPTS_DIR}
  cp ${species_training_set} ${SAVE_DIR}/${SCRIPTS_DIR}
fi

if [ ! -d ${SAVE_DIR}/${DATA_DIR} ]; then
  mkdir -p ${SAVE_DIR}/${DATA_DIR}/demux_results
  mkdir ${SAVE_DIR}/${DATA_DIR}/denoising_results
  mkdir ${SAVE_DIR}/${DATA_DIR}/core_metrics_results
  mkdir ${SAVE_DIR}/${DATA_DIR}/qza_files
  mkdir ${SAVE_DIR}/${RAW_DATA_DIR}

  cp -r ${project_dir}/QIIME_output ${SAVE_DIR}/${RAW_DATA_DIR} && \
  rm ${SAVE_DIR}/${RAW_DATA_DIR}/QIIME_output/demux.qza

  cp ${project_dir}/QIIME_output/demux_stat/per-sample-fastq-counts.csv ${SAVE_DIR}/${DATA_DIR}/demux_results

  cp ${project_dir}/QIIME_output/${QIIME_DENOISE}/feature_table/feature-table.tsv ${SAVE_DIR}/${DATA_DIR}/denoising_results
  cp ${project_dir}/QIIME_output/${QIIME_DENOISE}/taxonomy/taxonomy.tsv ${SAVE_DIR}/${DATA_DIR}/denoising_results
  
  cp ${project_dir}/QIIME_output/${QIIME_DENOISE}/core-metrics-unrarefied/faith_pd_unrarefied.tsv ${SAVE_DIR}/${DATA_DIR}/core_metrics_results
  cp ${project_dir}/QIIME_output/${QIIME_DENOISE}/core-metrics-unrarefied/uu_unrarefied.tsv ${SAVE_DIR}/${DATA_DIR}/core_metrics_results
  cp ${project_dir}/QIIME_output/${QIIME_DENOISE}/core-metrics-unrarefied/wu_unrarefied.tsv ${SAVE_DIR}/${DATA_DIR}/core_metrics_results
  
  cp ${project_dir}/QIIME_output/${QIIME_DENOISE}/representative-seqs.qza ${SAVE_DIR}/${DATA_DIR}/qza_files
  cp ${project_dir}/QIIME_output/${QIIME_DENOISE}/table.qza ${SAVE_DIR}/${DATA_DIR}/qza_files
  cp ${project_dir}/QIIME_output/${QIIME_DENOISE}/taxonomy/classification.qza ${SAVE_DIR}/${DATA_DIR}/qza_files

fi

if [ ! -d ${SAVE_DIR}/${META_DIR} ]; then
  mkdir ${SAVE_DIR}/${META_DIR}
  cp ${project_dir}/${mapping} ${SAVE_DIR}/${META_DIR}
fi
