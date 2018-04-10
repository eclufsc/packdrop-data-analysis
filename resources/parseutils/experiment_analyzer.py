from parseutils.experiment_groups import InputActionGroup
from parseutils.directory_resolver import DirectoryResolver

class ExperimentAnalyzer:
  """A class that links the data groups of an experiment to the parsing triggers"""

  def __init__(self, experiment_name):
    self.experiment = experiment_name
    self.groups = dict()
    self.raw = DirectoryResolver.raw_data_dir(experiment_name)
    self.parsed = DirectoryResolver.parsed_data_dir(experiment_name)

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
      for filename in file_group.files:
        full_path = self.raw + filename
        self.parse_file(full_path, action_group)

      if InputActionGroup.ControlAction.AFTER_PARSE in action_group.control_actions:
        action_group.control_actions[InputActionGroup.ControlAction.AFTER_PARSE]()