[Executioner]
    type = Transient

    solve_type = NEWTON
    petsc_options_iname = '-pc_type -pc_factor_shift_type'
    petsc_options_value = 'lu NONZERO'
    #solve_type = PJFNK
    #petsc_options = ' -snes_ksp_ew'
    #petsc_options_iname = '-ksp_gmres_restart'
    #petsc_options_value = '101'

    l_max_its = 100
    nl_max_its = 100
    nl_rel_tol = 1e-9
    nl_abs_tol = 1e-9
    l_tol = 1e-9
    start_time = 0.0
    end_time = ${endtime}
    dtmin =0.1
    residual_and_jacobian_together = true

    [./TimeStepper]
      #type = FunctionDT
      #function = dts
      # Tells the execuitioner to solve at the same time points. Not sure what happens if it doesn't solve.
      type = CSVTimeSequenceStepper
      file_name = ${time_file}
      column_index = 0
    [../]
  []