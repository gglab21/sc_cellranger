version 1.0
workflow GenerateSampleMap {
  input {
    Array[String] sample_names
    Array[String] file_paths
    String sample_map_name
  }
  
  call GenerateSampleMapFile {
    input:
      sample_names = sample_names,
      file_paths = file_paths,
      outfile = sample_map_name + ".sample_map"
  }
  
  output {
    File sample_map = GenerateSampleMapFile.sample_map
  }

}


# TASK DEFINITIONS
task GenerateSampleMapFile {
  input{
    # Command parameters
    Array[String] sample_names
    Array[String] file_paths
    String outfile 
    
    # Runtime parameters
    String docker = "python:latest"
    Int machine_mem_gb = 7
    Int disk_space_gb = 100
    Int preemptible_attempts = 3
  }
    command <<<
    set -oe pipefail
    
    python << CODE
    file_paths = ['~{sep="','" file_paths}']
    sample_names = ['~{sep="','" sample_names}']

    if len(file_paths)!= len(sample_names):
      print("Number of File Paths does not Equal Number of File Names")
      exit(1)

    with open("sample_map_file.txt", "w") as fi:
      fi.write("sample_id,molecule_h5\n")
      for i in range(len(file_paths)):
        fi.write(sample_names[i] + "," + file_paths[i][5:] + "\n") 

    CODE
    mv sample_map_file.txt ~{outfile}
    >>>

    runtime {
        docker: docker
        memory: machine_mem_gb + " GB"
        disks: "local-disk " + disk_space_gb + " HDD"
        preemptible: 3
    }

    output {
        File sample_map = outfile
    }
}
