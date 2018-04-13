from parseutils.experiment_groups import InputActionGroup

class CsvOutputter:
  """Class that wraps some of the code that must be used in order to provide triggers that writes into a csv file during parsing."""
  def __init__(self, filename, header_vars):
    self.filename = filename
    self.attributes = [''] * len(header_vars)

  def write(self):
    self.fref.write(','.join(self.attributes) + "\n")

  def open(self):
    self.fref = open(self.filename, 'w')
    
  def write_header(self, header_vars):
    with open(self.filename, 'w') as fp:
      fp.write(','.join(header_vars) + "\n")

  def append(self):
    self.fref = open(self.filename, 'a')

  def close(self):
    self.fref.close()
