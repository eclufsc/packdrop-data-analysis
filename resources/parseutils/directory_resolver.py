import os
import sys

class DirectoryResolver:
  """An utility and static class that resolves the path for the directory hierarchy assuming that the script will be run inside the experiments folder"""
  raw_data_dirname = "raw-data"
  parsed_data_dirname = "parsed-data"

  def join_experiment_path(experiment_name, dirname):
    return os.path.realpath(os.path.join(os.path.dirname(sys.argv[0]), experiment_name, dirname)) + os.sep

  def raw_data_dir(experiment_name):
    return DirectoryResolver.join_experiment_path(experiment_name, DirectoryResolver.raw_data_dirname)

  def parsed_data_dir(experiment_name):
    return DirectoryResolver.join_experiment_path(experiment_name, DirectoryResolver.parsed_data_dirname)

  def output_abspath(experiment_name, outfile_name):
    return os.path.join(DirectoryResolver.join_experiment_path(experiment_name, DirectoryResolver.parsed_data_dirname), outfile_name)