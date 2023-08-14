task cellranger_ag {
  String mol_hd5
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

    tar czf count.tar.gz count

  }

  output {
  File aggregation = "aggregation.csv"
  File aggregate_out = "count.tar.gz"
  File web = "web_summary.html"
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

workflow cellranger_aggregate {
  call cellranger_ag
}
