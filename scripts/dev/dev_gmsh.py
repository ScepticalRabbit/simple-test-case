'''
================================================================================
License: MIT
Copyright (C) 2024 The Computer Aided Validation Team
================================================================================
'''
import time
from pathlib import Path
from mooseherder import GmshRunner


GMSH_FILE = Path('models/meshes/stc-full.geo')
USER_DIR = Path.home()


def main() -> None:

    gmsh_runner = GmshRunner(USER_DIR / 'moose-workdir/gmsh/bin/gmsh')

    gmsh_start = time.perf_counter()
    gmsh_runner.run(GMSH_FILE)
    gmsh_run_time = time.perf_counter()-gmsh_start

    print("\n"+"="*80)
    print(f'Gmsh run time = {gmsh_run_time:.2f} seconds')
    print("="*80+"\n")


if __name__ == '__main__':
    main()

