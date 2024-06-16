'''
================================================================================
License: MIT
Copyright (C) 2024 The Computer Aided Validation Team
================================================================================
'''
import time
import shutil
from pathlib import Path
from mooseherder import (MooseConfig,
                         MooseRunner,
                         GmshRunner)


GMSH_FILE = Path('models/meshes/stc.geo')
MOOSE_FILE = Path('scripts/meshtest/mesh-tester-threeD.i')
USER_DIR = Path.home()


def main() -> None:

    gmsh_runner = GmshRunner(USER_DIR / 'gmsh/bin/gmsh')

    gmsh_start = time.perf_counter()
    gmsh_runner.run(GMSH_FILE)
    gmsh_run_time = time.perf_counter()-gmsh_start

    msh_file = 'stc.msh'
    shutil.copyfile(GMSH_FILE.parent / msh_file,
                    MOOSE_FILE.parent / msh_file)


    config = {'main_path': USER_DIR / 'moose',
            'app_path': USER_DIR / 'proteus',
            'app_name': 'proteus-opt'}

    moose_config = MooseConfig(config)
    moose_runner = MooseRunner(moose_config)

    moose_runner.set_run_opts(n_tasks = 1,
                              n_threads = 8,
                              redirect_out = False)

    moose_start_time = time.perf_counter()
    moose_runner.run(MOOSE_FILE)
    moose_run_time = time.perf_counter() - moose_start_time

    print()
    print("="*80)
    print(f'Gmsh run time = {gmsh_run_time:.2f} seconds')
    print(f'MOOSE run time = {moose_run_time:.3f} seconds')
    print("="*80)
    print()

if __name__ == '__main__':
    main()

