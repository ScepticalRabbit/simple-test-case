#-------------------------------------------------------------------------
# pyvale: gmsh,3Dstc,1mat,thermal,steady,
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
#_* MOOSEHERDER VARIABLES - START

# NOTE: only used for transient solves
endTime = 1
timeStep = 1

# Thermal Loads/BCs
coolantTemp = 100 # degC
surfHeatPower = 10000 # W
surfArea = ${fparse 50e-3*25e-3} # m^2
surfHeatFlux = ${fparse surfHeatPower/surfArea} # W.m^-2

# Mesh file string
mesh_file = 'stc-full.msh'
elem_order = SECOND

#** MOOSEHERDER VARIABLES - END
#-------------------------------------------------------------------------

[Mesh]
    type = FileMesh
    file = ${mesh_file}
[]

[Variables]
    [temperature]
        family = LAGRANGE
        order = ${elem_order}
        initial_condition = ${coolantTemp}
    []
[]

[Kernels]
    [heat_conduction]
        type = HeatConduction
        variable = temperature
    []
[]

[Functions]
    [copper_thermal_expansion]
        type = PiecewiseLinear
        xy_data = '
            20 1.67e-05
            50 1.7e-05
            100 1.72e-05
            150 1.75e-05
            200 1.77e-05
            250 1.78e-05
            300 1.8e-05
            350 1.81e-05
            400 1.82e-05
            450 1.84e-05
            500 1.85e-05
            550 1.87e-05
            600 1.88e-05
            650 1.9e-05
            700 1.91e-05
            750 1.93e-05
            800 1.96e-05
            850 1.98e-05
            900 2.01e-05
        '
    []
[]

[Materials]
    [copper_density]
        type = PiecewiseLinearInterpolationMaterial
        xy_data = '
          20 8940
          50 8926
          100 8903
          150 8879
          200 8854
          250 8829
          300 8802
          350 8774
          400 8744
          450 8713
          500 8681
          550 8647
          600 8612
          650 8575
          700 8536
          750 8495
          800 8453
          850 8409
          900 8363
        '
        variable = temperature
        property = density
        block = 'stc-vol'
    []
    [copper_thermal_conductivity]
        type = PiecewiseLinearInterpolationMaterial
        xy_data = '
          20 401
          50 398
          100 395
          150 391
          200 388
          250 384
          300 381
          350 378
          400 374
          450 371
          500 367
          550 364
          600 360
          650 357
          700 354
          750 350
          800 347
          850 344
          900 340
          950 337
          1000 334
        '
        variable = temperature
        property = thermal_conductivity
        block = 'stc-vol'
    []
    [copper_specific_heat]
        type = PiecewiseLinearInterpolationMaterial
        xy_data = '
          20 388
          50 390
          100 394
          150 398
          200 401
          250 406
          300 410
          350 415
          400 419
          450 424
          500 430
          550 435
          600 441
          650 447
          700 453
          750 459
          800 466
          850 472
          900 479
          950 487
          1000 494
        '
        variable = temperature
        property = specific_heat
        block = 'stc-vol'
    []
    [coolant_heat_transfer_coefficient]
        type = PiecewiseLinearInterpolationMaterial
        xy_data = '
          1 4
          100 109.1e3
          150 115.9e3
          200 121.01e3
          250 128.8e3
          295 208.2e3
        '
        variable = temperature
        property = heat_transfer_coefficient
        boundary = 'bc-pipe-htc'
    []
[]

[BCs]
    [heat_flux_out]
        type = ConvectiveHeatFluxBC
        variable = temperature
        boundary = 'bc-pipe-htc'
        T_infinity = ${coolantTemp}
        heat_transfer_coefficient = heat_transfer_coefficient
    []
    [heat_flux_in]
        type = NeumannBC
        variable = temperature
        boundary = 'bc-top-heatflux'
        value = ${surfHeatFlux}
    []
[]

[Executioner]
    type = Transient
    solve_type = 'PJFNK'
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = 'hypre    boomeramg'
    end_time= ${endTime}
    dt = ${timeStep}
[]

[Postprocessors]
    [temp_max]
        type = NodalExtremeValue
        variable = temperature
    []
    [temp_avg]
        type = AverageNodalVariableValue
        variable = temperature
    []
[]

[Outputs]
    exodus = true
[]