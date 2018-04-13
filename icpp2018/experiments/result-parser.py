from experimentaux import *

wrapper = SDumontWrapper()
actions = SDumontActions(wrapper)
triggers = CharmLogTriggers(actions)

wrapper.set_files_first_exp('all', ['144', '240', '336', '384', '480', '576', '672', '768'])
wrapper.set_files_first_exp('leanmd', ['288', '576', '1142'])
wrapper.set_files_first_exp('lbtest', ['1142', '1728'])

wrapper.set_files_second_exp(['30', '60'], ['dist', 'pdlb', 'refine', 'dist'])

wrapper.write_header()

for regex, func in triggers.mapping.items():
  wrapper.action_register.map_action(regex, func)

wrapper.analysis.analyze()
