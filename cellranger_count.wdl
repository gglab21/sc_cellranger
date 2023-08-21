task cellranger_sc {
  String fastq_files_dir
  File reference_transcriptome
  String sample_id
  String output_path

  ## cellranger count options

  ## virt size
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt

  command {
  set -euo pipefail
  mkdir reference_trans

  tar -zxvf ${reference_transcriptome} -C reference_trans
  ls -l
  echo "xxx"
  pwd
  cellranger count \
    --id=${sample_id} \
    --fastqs=${fastq_files_dir}
    --sample=${sample_id} \
    --transcriptome=/cromwell_root/reference_trans/ \
    --localcores=${num_threads} \
    --localmem=${memory}

    gsutil -m mv $(sample_id)/* ${output_path}


  }

  output {
  File analysis = "${sample_id}/analysis"
  File cloupe = "${sample_id}/cloupe.cloupe"
  File filt_feat = "${sample_id}/filtered_feature_bc_matrix"
  File filt_feat_h5 = "${sample_id}/filtered_feature_bc_matrix.h5"
  File metrics = "${sample_id}/metrics_summary.csv"
  File molecule = "${sample_id}/molecule_info.h5"
  File bam = "${sample_id}/possorted_genome_bam.bam"
  File bam_index = "${sample_id}/possorted_genome_bam.bam.bai"
  File raw_feat = "${sample_id}/raw_feature_bc_matrix"
  File raw_feat_h5 = "${sample_id}/raw_feature_bc_matrix.h5"
  File web = "${sample_id}/web_summary.html"
  }

  runtime{
    docker: "nfcore/cellranger:7.1.0"
    memory: "${memory}GB"
    disks: "local-disk ${disk_space} HDD"
    cpu: "${num_threads}"
    preemptible: "${num_preempt}"
  }

  meta {
    author: "Gabriel Goodney"
  }

}

workflow cellranger_count {
  call cellranger_sc
}
