from experimentaux import *

def g5k_files(wrapper):
  g5k_lbs = ['dist', 'greedy', 'nolb', 'pdlb', 'refine']
  
  #wrapper.set_g5k_files('lbtest', ['mesh2d', 'mesh3d', 'ring'], g5k_lbs)
  #wrapper.set_g5k_files('leanmd', ['short', 'long'], g5k_lbs)

def sdumont_files(wrapper):
  wrapper.set_sdumont_initial_files('all', ['144', '240', '336', '384', '480', '576', '672', '768'])
  #wrapper.set_sdumont_initial_files('leanmd', ['288', '576', '1142'])
  wrapper.set_sdumont_initial_files('lbtest', ['1142', '1728'])
  #wrapper.set_sdumont_freq_files(['30', '60'], ['dist', 'pdlb', 'refine', 'dist'])

file_map_func = {
  'g5k': g5k_files,
  'sdumont': sdumont_files
}

for experiment in ['g5k', 'sdumont']:
  wrapper = ExperimentWrapper(experiment)
  actions = ExperimentActions(wrapper)
  triggers = CharmLogTriggers(actions)

  file_map_func[experiment](wrapper)
  wrapper.write_header()
  
  for regex, func in triggers.mapping.items():
    wrapper.action_register.map_action(regex, func)

  wrapper.analysis.analyze()