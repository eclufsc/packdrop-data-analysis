from enum import Enum
import re

class InputFileGroup:
  """A class that wraps a filename pattern that designates a group. This module is able to generate all file names following a simple regex form"""
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
    AFTER_PARSE = 1

  def __init__(self):
    self.action_map = dict()
    self.control_actions = dict()

  def map_control_action(self, control_tag, action):
    self.control_actions[control_tag] = action

  def map_action(self, regex, action):
    self.action_map[re.compile(regex)] = action