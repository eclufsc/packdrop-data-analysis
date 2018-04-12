from parseutils.file_outputter import CsvOutputter
from parseutils.experiment_analyzer import ExperimentAnalyzer
from parseutils.experiment_groups import InputFileGroup, InputActionGroup

class SDumontTest:
  header_vars = ['app', 'sched', 'plat_size', 'sched_time', 'wildmetric']
  header_vars_map = {'app': 0, 'sched': 1, 'plat_size': 2, 'sched_time': 3, 'wildmetric': 4}
  outputter = CsvOutputter('sdumont.csv', header_vars)

  def __init__(self):
    self.action_group = InputActionGroup()
    self.analysis = ExperimentAnalyzer('sdumont')

    self.action_group.map_control_action(InputActionGroup.ControlAction.BEFORE_PARSE, SDumontTest.outputter.append)
    self.action_group.map_control_action(InputActionGroup.ControlAction.AFTER_PARSE, SDumontTest.outputter.close)

  def set_files(self, application_name, sizes):
    file_group = InputFileGroup('-', 'out', ['lb-test-results'], [application_name], sizes)
    self.analysis.map_group(file_group, self.action_group)

  def write_header():
    SDumontTest.outputter.write_header(SDumontTest.header_vars)

  def set_metric(metric, value):
    SDumontTest.outputter.attributes[SDumontTest.header_vars_map[metric]] = value

  def print_line():
    SDumontTest.outputter.write()

  def found_sched(line, result):
    SDumontTest.set_metric('sched', result.groups(1)[0])

  def found_app_and_platsize(line, result):
    SDumontTest.set_metric('app', result.groups(1)[0])
    SDumontTest.set_metric('plat_size', result.groups(1)[1])

  def found_leanmd_app(line, result):
    SDumontTest.set_metric('app', 'leanmd')

  def found_leanmd_period(line, result):
    SDumontTest.set_metric('wildmetric', result.groups(1)[0])

  def found_topology(line, result):
    SDumontTest.set_metric('wildmetric', result.groups(1)[0])

  def found_sched_time(line, result):
    SDumontTest.set_metric('sched_time', result.groups(1)[0])
    SDumontTest.print_line()

  def found_leanmd_platsize(line, result):
    SDumontTest.set_metric('plat_size', result.groups(1)[0])

# Analyzing the SDumont experiments
sdumont = {'lbtest': SDumontTest(), 'leanmd': SDumontTest(), 'all': SDumontTest()}

#sdumont['lbtest'].set_files('lbtest', ['288', '576', '1142', '1728'])
#sdumont['leanmd'].set_files('leanmd', ['288', '576', '1142'])
sdumont['all'].set_files('all', ['144', '240', '336', '384', '480', '576', '672', '768'])

def register_actions_lbtest(test, actiong):
  pass

def register_actions_all(test, actiong):
  actiong.map_action(r'\[0\] (.+?)LB created', SDumontTest.found_sched)
  actiong.map_action(r'MOLECULAR DYNAMICS START UP', SDumontTest.found_leanmd_app)
  actiong.map_action(r'Running (.+?) on (\d+?) processors', SDumontTest.found_app_and_platsize)
  actiong.map_action(r'Selecting Topology (.*)', SDumontTest.found_topology)
  actiong.map_action(r'strategy finished at .+? duration (.+?) s', SDumontTest.found_sched_time)
  actiong.map_action(r'step \d+? finished at .+? duration (.+?) ', SDumontTest.found_sched_time)
  actiong.map_action(r'LB Period:(\d+)', SDumontTest.found_leanmd_period)
  actiong.map_action(r' numPes (\d+)', SDumontTest.found_leanmd_platsize)

def register_actions_leanmd(test, actiong):
  pass

action_register = {'lbtest': register_actions_lbtest, 'leanmd': register_actions_leanmd, 'all': register_actions_all}
SDumontTest.write_header()

for tag,test in sdumont.items():
  action_register[tag](test, test.action_group)
  test.analysis.analyze()
