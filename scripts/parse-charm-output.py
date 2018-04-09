import os
import re
from enum import Enum

class DirectoryResolver:
  """An utility and static class that resolves the path for the directory hierarchy"""
  raw_data_dirname = "raw-data"
  experiments_dirname = "experiments"
  parsed_data_dirname = "parsed-data"

  def home_dir():
    script_dir = os.path.realpath(__file__)
    sub_dir = os.path.join(os.path.dirname(script_dir), os.pardir)
    return os.path.realpath(sub_dir)

  def project_dir(project_name):
    return os.path.realpath(os.path.join(DirectoryResolver.home_dir(), project_name)) + os.sep

  def experiments_dir(project_name, experiment_name):
    return os.path.realpath(os.path.join(DirectoryResolver.project_dir(project_name), DirectoryResolver.experiments_dirname, experiment_name)) + os.sep

  def raw_data_dir(project_name, experiment_name):
    return os.path.realpath(os.path.join(DirectoryResolver.experiments_dir(project_name, experiment_name), DirectoryResolver.raw_data_dirname)) + os.sep

  def parsed_data_dir(project_name, experiment_name):
    return os.path.realpath(os.path.join(DirectoryResolver.experiments_dir(project_name, experiment_name), DirectoryResolver.parsed_data_dirname)) + os.sep

class InputFileGroup:
  """A class that wraps a filename pattern and generates all the filenames which will represent an experiment group"""
  def count_name_variations(self, *wildcards):
    name_count = 1
    for wildvar in wildcards:
      variations = 0
      for wildval in wildvar:
        variations += 1
      name_count *= variations
    return name_count

  def generate_names(self, separator, extension, *wildcards):
    name_list = list()
    nnames = self.count_name_variations(*wildcards)

    for i in range(0,nnames):
      name_list.append("")

    for wildvar in wildcards:
      var_len = len(wildvar)
      for val_i in range(0,len(name_list)):
        name_list[val_i] = name_list[val_i] + wildvar[val_i%var_len] + separator

    for i in range(0, len(name_list)):
      name_list[i] = name_list[i][:-1]
      name_list[i] = name_list[i] + "." + extension
    
    return name_list

  def __init__(self, separator, extension, *wildcards):
    self.files = self.generate_names(separator, extension, *wildcards)

class InputActionGroup:
  """A class that wraps the links from a set of regex to a set of actions which will be taken during the analysis"""

  class ControlAction(Enum):
    BEFORE_PARSE = 1
    AFTER_PARSE = 2

  def __init__(self):
    self.action_map = dict()
    self.control_actions = dict()

  def map_control_action(self, control_tag, action):
    self.control_actions[control_tag] = action

  def map_action(self, regex, action):
    self.action_map[re.compile(regex)] = action

class ExperimentAnalyzer:
  """A class that wraps the useful directory names in an experiment analysis"""

  def __init__(self, project_name, experiment_name):
    self.experiment = experiment_name
    self.project = project_name
    self.groups = dict()
    self.raw = DirectoryResolver.raw_data_dir(project_name, experiment_name)
    self.parsed = DirectoryResolver.parsed_data_dir(project_name, experiment_name)

  def map_group(self, file_group, action_group):
    self.groups[file_group] = action_group

  def parse_file(self, file_path, actions):
    with open(file_path, 'r') as fp:
      for line in fp:
        for regex, action in actions.action_map.items():
          result = regex.search(line)
          if result:
            action(line, result)

  def analyze(self):
    for file_group, action_group in self.groups.items():
      if InputActionGroup.ControlAction.BEFORE_PARSE in action_group.control_actions:
        action_group.control_actions[InputActionGroup.ControlAction.BEFORE_PARSE]()
      
      for filename in file_group.files:
        full_path = self.raw + filename
        self.parse_file(full_path, action_group)

      if InputActionGroup.ControlAction.AFTER_PARSE in action_group.control_actions:
        action_group.control_actions[InputActionGroup.ControlAction.AFTER_PARSE]()

# THIS IS AN EXAMPLE!!!
analysis = ExperimentAnalyzer("icpp2018", "g5k")

lbtest_fgroup = InputFileGroup("_", "res", ['lbtest'], ['mesh2d'], ['greedy'])

class Outputter:

  def before(self):
    self.fref = open('output.csv', 'w')
    self.fref.write('app_time\n')

  def after(self):
    self.fref.close()

  def parse_app_time(self, line, regex_result):
    self.fref.write(regex_result.group(1) + "\n")

out = Outputter()

lbtest_agroup = InputActionGroup()
lbtest_agroup.map_action(r"TIME PER STEP\s+?150\s+?\d+?\.\d+?\s+?(\d+?\.\d+)", out.parse_app_time)

lbtest_agroup.map_control_action(InputActionGroup.ControlAction.BEFORE_PARSE, out.before)
lbtest_agroup.map_control_action(InputActionGroup.ControlAction.AFTER_PARSE, out.after)

analysis.map_group(lbtest_fgroup, lbtest_agroup)
analysis.analyze()