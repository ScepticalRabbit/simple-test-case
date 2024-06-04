'''
================================================================================
License: MIT
Copyright (C) 2024 The Computer Aided Validation Team
================================================================================
'''
from pprint import pprint
from pathlib import Path
from mooseherder import (MooseHerd,
                         MooseRunner,
                         MooseConfig,
                         GmshRunner,
                         InputModifier,
                         DirectoryManager)

USER_DIR = Path.home()

def main():
    print("="*80)
    print('MESH REFINEMENT STUDY')
    print("="*80)

    gmsh_input = Path('models/meshes/stc-nopipe.geo')
    moose_input = Path('models/thermal/stc-thermal.i')
    mesh_ref = (1,2,3,4)

    moose_modifier = InputModifier(moose_input,'#','')
    config = {'main_path': USER_DIR / 'moose',
            'app_path': USER_DIR / 'moose-workdir/proteus',
            'app_name': 'proteus-opt'}
    moose_config = MooseConfig(config)
    moose_runner = MooseRunner(moose_config)
    moose_runner.set_run_opts(n_tasks = 1,
                              n_threads = 2,
                              redirect_out = True)

    gmsh_modifier = InputModifier(gmsh_input,'//',';')
    gmsh_runner = GmshRunner(USER_DIR / 'moose-workdir/gmsh/bin/gmsh')
    gmsh_runner.set_input_file(gmsh_input)


    sim_runners = [gmsh_runner,moose_runner]
    input_modifiers = [gmsh_modifier,moose_modifier]
    dir_manager = DirectoryManager(n_dirs = 1)

    herd = MooseHerd(sim_runners,input_modifiers,dir_manager)
    herd.set_num_para_sims(n_para = 4)

    dir_manager.set_base_dir(Path('data/'))
    dir_manager.clear_dirs()
    dir_manager.create_dirs()


    var_sweep = list()

    for mm in mesh_ref:
        var_sweep.append([{'mesh_ref':mm},None])

    print('Mesh sweep variables:')
    for vv in var_sweep:
        print(vv)

    print("\n"+"-"*80)
    print('Running mesh refinement sweep')
    print("-"*80+"\n")

    herd.run_sequential(var_sweep)
    #herd.run_para(var_sweep)

    print(f'Run time (parallel) = {herd.get_sweep_time():.3f} seconds')
    print("-"*80)
    print()

if __name__ == '__main__':
    main()

