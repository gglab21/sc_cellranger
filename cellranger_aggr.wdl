task cellranger_ag {
  Array[File] mol_hd5
  Array[String] sample_id
  File sample_map
  String set_id

  ## cellranger count options

  ## virt size
  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt

  command {
  set -euo pipefail

  cellranger aggr \
    --id=${set_id} \
    --csv=${sample_map} \
    --localcores=${num_threads} \
    --localmem=${memory}

  ls
  tar czf ${set_id}_outs.tar.gz ${set_id}/outs

  }

  output {
  File aggregate_out = "${set_id}_outs.tar.gz"
  }

  runtime {
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

workflow cellranger_aggregate {
  call cellranger_ag
}
