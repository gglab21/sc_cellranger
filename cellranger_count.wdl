task cellranger_sc {
  Array[File] fastq_r1_files
  Array[File] fastq_r2_files
  String fastq_files_dir
  File reference_transcriptome
  String sample_id
  String output_path
  Int len_arr = length(fastq_r1_files)

  ## cellranger count options

  ## virt size
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt

  command <<<
  set -euo pipefail
  mkdir reference_trans
  tar -zxvf ${reference_transcriptome} -C reference_trans --strip-components=1

  #Reformat fq names to 10x input format
  fq_arr=($(ls ${fastq_files_dir}))

  for (( c=0; c<${len_arr}; c++ ));do
    mid1=($(echo ${fastq_r2_files[$c]} | cut -d'_' -f4-6))
    mv ${fastq_files_dir}${sample_id}/${fastq_r2_files[$c]} ${fastq_files_dir}${sample_id}/${sample_id}"_"$mid1"_00"$c".fastq.gz"
  done


  cellranger count \
    --id=${sample_id} \
    --transcriptome=reference_trans/ \
    --fastqs=${fastq_files_dir} \
    --localcores=${num_threads} \
    --localmem=${memory}

  tar czf ${sample_id}/outs/${sample_id}_analysis.tar.gz ${sample_id}/outs/analysis
  tar czf ${sample_id}/outs/${sample_id}_filt_ft_bc_matrix.tar.gz ${sample_id}/outs/filtered_feature_bc_matrix
  tar czf ${sample_id}/outs/${sample_id}_raw_ft_bc_matrix.tar.gz ${sample_id}/outs/raw_feature_bc_matrix

  >>>

  output {
  File analysis = "${sample_id}/outs/${sample_id}_analysis.tar.gz"
  File cloupe = "${sample_id}/outs/cloupe.cloupe"
  File filt_feat = "${sample_id}/outs/${sample_id}_filt_ft_bc_matrix.tar.gz"
  File filt_feat_h5 = "${sample_id}/outs/filtered_feature_bc_matrix.h5"
  File metrics = "${sample_id}/outs/metrics_summary.csv"
  File molecule = "${sample_id}/outs/molecule_info.h5"
  File bam = "${sample_id}/outs/possorted_genome_bam.bam"
  File bam_index = "${sample_id}/outs/possorted_genome_bam.bam.bai"
  File raw_feat = "${sample_id}/outs/${sample_id}_raw_ft_bc_matrix.tar.gz"
  File raw_feat_h5 = "${sample_id}/outs/raw_feature_bc_matrix.h5"
  File web = "${sample_id}/outs/web_summary.html"
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
