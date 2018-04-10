from parseutils.file_outputter import CsvOutputter
from parseutils.experiment_analyzer import ExperimentAnalyzer
from parseutils.experiment_groups import InputFileGroup, InputActionGroup

class Icpp2018Parser:
  def __init__(self, action_group, filename, header_vars):
    self.out = CsvOutputter(action_group, filename, header_vars)

  def found_elements(self, line, result):
    print('found')
    self.out.attributes[0] = result.group(1)

  def flush(self, line, result):
    self.out.write_seq()


g5k_lbtest = ExperimentAnalyzer("g5k")

g5k_fgroup = InputFileGroup('_', r'res', ['lbtest'], ['mesh2d'], ['dist'])
g5k_agroup = InputActionGroup()
parser = Icpp2018Parser(g5k_agroup, 'output.csv', ['elements'])

g5k_agroup.map_action(r'Generating topology 1 for (\d+?) elements', parser.found_elements)
g5k_agroup.map_action(r'First node busywaits', parser.flush)

g5k_lbtest.map_group(g5k_fgroup, g5k_agroup)
g5k_lbtest.analyze()