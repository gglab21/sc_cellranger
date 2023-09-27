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
  file_paths = ~{sep="','" file_paths}
  sample_names = ~{sep="','" sample_names}

  if len(file_paths)!= len(sample_names):
    print("Number of samples not equal to number of files")
    exit(1)
  with open("map.csv","w") as fin:
    fin.write("sample_id,molecule_h5\n")
    for i in range(len(file_paths)):
      fin.write(sample_names[i] + ", " + file_paths[i] +"\n")
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
