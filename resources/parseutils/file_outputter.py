from parseutils.experiment_groups import InputActionGroup

class CsvOutputter:
  """Class that wraps some of the code that must be used in order to provide triggers that writes into a csv file during parsing."""
  def __init__(self, action_group, filename, header_vars):
    self.fref = open(filename, 'w')
    self.fref.write(','.join(header_vars))
    self.attributes = [''] * len(header_vars)
    action_group.map_control_action(InputActionGroup.ControlAction.AFTER_PARSE, self.after)

  def write_seq(self):
    self.fref.write(','.join(self.attributes) + "\n")

  def after(self):
    self.fref.close()
