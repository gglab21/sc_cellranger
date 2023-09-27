task gen_samp_map {
  Array[String] sample_names
  Array[String] input_path
  String map_csv

  Int memory
  Int disk_space
  Int num_threads
  Int num_preempt

  command <<<
  set -euo pipefail
  python << CODE
  paths = ['~{sep="','" input_path}']
  samps = ['~{sep="','" sample_names}']

  if len(paths)!= len(samps):
    print("Number of samples not equal to number of files")
    exit(1)
  with open("map.csv","w") as fin:
    fin.write("sample_id,molecule_h5\n")
    for i in range(len(paths)):
      fin.write(samps[i] + ", " + paths[i] +"\n")
  CODE
  mv map.csv ${map_csv}
  >>>

  output {
    File sample_map = map_csv
  }

  runtime {
    docker: "python:latest"
    memory: "${memory}GB"
    disks: "local-disk ${disk_space} HDD"
    cpu: "${num_threads}"
    preemptible: "${num_preempt}"
  }
  meta {
    author: "Gabriel Goodney"
  }
}

workflow sample_map {
  call gen_samp_map
}
