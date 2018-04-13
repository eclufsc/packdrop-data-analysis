from parseutils.file_outputter import *
from parseutils.experiment_analyzer import *
from parseutils.experiment_groups import *
from parseutils.directory_resolver import *

from enum import Enum

def list_append(lst, item):
  lst.append(item)
  return lst

class ExperimentType(Enum):
  Schedtime = 0
  Apptime = 1
  Steptime = 2

class ExperimentOrganizer:
  """A class to organize the header of the different files in an experiment"""
  common_hdr = ['app', 'sched', 'plat_size', 'wildmetric']
  metric_position = {
    'app': 0,
    'sched': 1,
    'plat_size': 2,
    'wildmetric': 3
  }

  headers = {
    ExperimentType.Schedtime: list_append(common_hdr[:], 'sched_time'),
    ExperimentType.Apptime: list_append(common_hdr[:], 'app_time'),
    ExperimentType.Steptime: list_append(common_hdr[:], 'step_time')
  }
  
  def outfiles(experiment_name):
    return {
      ExperimentType.Schedtime: DirectoryResolver.output_abspath(experiment_name, experiment_name + '-schedtime.csv'),
      ExperimentType.Apptime: DirectoryResolver.output_abspath(experiment_name, experiment_name + '-apptime.csv'),
      ExperimentType.Steptime: DirectoryResolver.output_abspath(experiment_name, experiment_name + '-steptime.csv')
    }

  def metric_csv_position(metric):
    if(metric in ExperimentOrganizer.metric_position):
      return ExperimentOrganizer.metric_position[metric]
    return 4

class ExperimentWrapper:
  """SDumontWrapper keeps the analysis object and all the outputters linked to a single action_group for the sdumont data"""
  
  def open_all(self):
    """Open all the output files for the experiment"""
    for etype in ExperimentType:
      self.outputters[etype].append()

  def close_all(self):
    """Close all the output files opened for the experiment"""
    for etype in ExperimentType:
      self.outputters[etype].close()

  def write_header(self):
    """Writes the header of all the csv files"""
    for etype in ExperimentType:
      self.outputters[etype].write_header(ExperimentOrganizer.headers[etype])

  def set_sdumont_initial_files(self, application_name, sizes):
    """Sets the file group of the first round of experiments that will be analyzed"""
    file_group = InputFileGroup('-', 'out', ['lb-test-results'], [application_name], sizes)
    self.analysis.map_group(file_group, self.action_register)

  def set_sdumont_freq_files(self, frequencies, scheds):
    """Sets the file group of the first round of experiments that will be analyzed. This function should not be needed if the name patterns would be carefully looked at"""
    file_group = InputFileGroup('_', 'res', ['3_freq_leanmd'], frequencies, scheds)
    self.analysis.map_group(file_group, self.action_register)

  def set_g5k_files(self, app, wildvals, scheds):
    """Sets the file group of the first round of experiments that will be analyzed. This function should not be needed if the name patterns would be carefully looked at"""
    file_group = InputFileGroup('_', 'res', [app], wildvals, scheds)
    self.analysis.map_group(file_group, self.action_register)

  def print_line(self, etype):
    self.outputters[etype].write()

  def set_metric(self, metric, val, etypes):
    for etype in etypes:
      self.outputters[etype].attributes[ExperimentOrganizer.metric_csv_position(metric)] = val

  def __init__(self, experiment_name):
    self.outputters = {}
    self.analysis = ExperimentAnalyzer(experiment_name)
    self.action_register = InputActionGroup()

    for etype in ExperimentType:
      self.outputters[etype] = CsvOutputter(ExperimentOrganizer.outfiles(experiment_name)[etype], ExperimentOrganizer.headers[etype])
    self.action_register.map_control_action(InputActionGroup.ControlAction.BEFORE_PARSE, self.open_all)
    self.action_register.map_control_action(InputActionGroup.ControlAction.AFTER_PARSE, self.close_all)

class ExperimentActions:
  """Class that executes all actions to notify the outputters to change their state and write lines into the files"""

  def found_sched(self, line, result):
    """Executed when the regex found the scheduler value in the log. Sets the sched data for all the experiments"""
    self.exp.set_metric('sched', result.groups(1)[0], [e for e in ExperimentType])

  def found_lb_test_app_and_platsize(self, line, result):
    """Executed when the regex found the app and platform size values in the lb_test log. Sets the sched data for all the experiments"""
    self.exp.set_metric('app', result.groups(1)[0], [e for e in ExperimentType])
    self.exp.set_metric('plat_size', result.groups(1)[1], [e for e in ExperimentType])

  def found_leanmd_app(self, line, result):
    """Executed when the regex found the app value in the leanmd log. Sets the app data for all the experiments"""
    self.exp.set_metric('app', 'leanmd', [e for e in ExperimentType])

  def found_leanmd_period(self, line, result):
    """Executed when the regex found the leanmd sched period value in the leanmd log. Sets the wildmetric data for all the experiments"""
    self.exp.set_metric('wildmetric', result.groups(1)[0], [e for e in ExperimentType])

  def found_topology(self, line, result):
    """Executed when the regex found the topology value in the lb_test log. Sets the wildmetric data for all the experiments"""
    self.exp.set_metric('wildmetric', result.groups(1)[0], [e for e in ExperimentType])

  def found_sched_time(self, line, result):
    """Executed when the regex found the scheduler time in the log. Sets the sched_time data for the relevant experiment"""
    self.exp.set_metric('sched_time', result.groups(1)[0], [ExperimentType.Schedtime])
    self.exp.print_line(ExperimentType.Schedtime)

  def found_leanmd_platsize(self, line, result):
    """Executed when the regex found the platform size value in the leanmd log. Sets the platform_size data for all the experiments"""
    self.exp.set_metric('plat_size', result.groups(1)[0], [e for e in ExperimentType])

  def found_apptime(self, line, result):
    self.exp.set_metric('app_time', result.groups(1)[0], [ExperimentType.Apptime])
    self.exp.print_line(ExperimentType.Apptime)

  def found_leanmd_step_time(self, line, result):
    self.exp.set_metric('step_time', result.groups(1)[0], [ExperimentType.Steptime])
    self.exp.print_line(ExperimentType.Steptime)

  def __init__(self, ewrapper):
    self.exp = ewrapper

class CharmLogTriggers:
  def __init__(self, actor):
    self.mapping = {
      r'\[0\] (.+?)LB created': actor.found_sched,
      r'MOLECULAR DYNAMICS START UP': actor.found_leanmd_app,
      r'Running (.+?) on (\d+?) processors': actor.found_lb_test_app_and_platsize,
      r'Selecting Topology (.*)': actor.found_topology,
      r'strategy finished at .+? duration (.+?) s': actor.found_sched_time,
      r'step \d+? finished at .+? duration (.+?) ': actor.found_sched_time,
      r'LB Period:(\d+)': actor.found_leanmd_period,
      r' numPes (\d+)': actor.found_leanmd_platsize,
      r'TIME\s+?PER\s+?STEP\s+?150\s+?(.+?) ': actor.found_apptime,
      r'Total application time (.+?) s': actor.found_apptime,
      r'Step \d+? Benchmark Time (.+?) ': actor.found_leanmd_step_time
    }