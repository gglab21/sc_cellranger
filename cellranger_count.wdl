task cellranger_sc {
  Array[File] fastq_r1_files
  Array[File] fastq_r2_files
  String fastq_files_dir
  File reference_transcriptome
  String sample_id
  String output_path
  Int len_arr = length(fastq_r1_files)
  Int c = 0
  Int d = 0
  String dollar = "$"

  ## cellranger count options

  ## virt size
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt

  command <<<
  set -exo pipefail
  mkdir reference_trans
  #tar -zxvf ${reference_transcriptome} -C reference_trans --strip-components=1
  ls ${fastq_files_dir}${sample_id}/
  ls -a
  #Reformat fq names to 10x input format
  echo fastq_r1_files[1]

  for i in ${sep=' ' fastq_r1_files};do
    echo "$i"
    mid1=($(echo "$i" | cut -d'_' -f7-8))
    mid2=($(echo $mid1 | sed -r 's/_R1/_R2/'))
    
    echo ${fastq_files_dir}${sample_id}/${sample_id}"_"$mid1"_00"$c".fastq.gz"
    fl=($(basename $i))
    cp $i ${fastq_files_dir}${sample_id}/${sample_id}"_"$mid1"_001.fastq.gz" 
    cp $i ${fastq_files_dir}${sample_id}/${sample_id}"_"$mid2"_001.fastq.gz"
    ls ${fastq_files_dir}${sample_id}/
    c=$c_1
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
