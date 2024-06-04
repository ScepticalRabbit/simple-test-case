#-------------------------------------------------------------------------
# pyvale: gmsh,3Dstc,1mat,thermal,steady,
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
#_* MOOSEHERDER VARIABLES - START

# NOTE: only used for transient solves
#endTime= 1
#timeStep = 1

# Thermal Loads/BCs
coolantTemp = 100.0      # degC
heatTransCoeff = 125.0e3 # W.m^-2.K^-1
surfHeatFlux = 5.0e6    # W.m^-2

# Material Properties: Pure (OFHC) Copper at 250degC
cuDensity = 8829.0  # kg.m^-3
cuThermCond = 384.0 # W.m^-1.K^-1
cuSpecHeat = 406.0  # J.kg^-1.K^-1

# Mesh file string
mesh_file = 'stc-nopipe.msh'

#** MOOSEHERDER VARIABLES - END
#-------------------------------------------------------------------------

[Mesh]
    type = FileMesh
    file = ${mesh_file}
  []

[Variables]
    [temperature]
        initial_condition = ${coolantTemp}
    []
[]

[Functions]
    [copper_thermal_expansion_fn]
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

[Kernels]
    [heat_conduction]
        type = HeatConduction
        variable = temperature
    []
[]

[Materials]
    [copper_thermal]
        type = HeatConductionMaterial
        thermal_conductivity = ${cuThermCond}
        specific_heat = ${cuSpecHeat}
    []
    [copper_density]
        type = GenericConstantMaterial
        prop_names = 'density'
        prop_values = ${cuDensity}
    []
[]

[BCs]
    [heat_flux_out]
        type = ConvectiveHeatFluxBC
        variable = temperature
        boundary = 'bc-pipe-htc'
        T_infinity = ${coolantTemp}
        heat_transfer_coefficient = ${heatTransCoeff}
    []
    [heat_flux_in]
        type = NeumannBC
        variable = temperature
        boundary = 'bc-top-heatflux'
        value = ${surfHeatFlux}
    []
[]

[Executioner]
    type = Steady
    #end_time= ${endTime}
    #dt = ${timeStep}
[]

[Postprocessors]
    [max_temp]
        type = NodalExtremeValue
        variable = temperature
    []
    [avg_temp]
        type = AverageNodalVariableValue
        variable = temperature
    []
[]

[Outputs]
    exodus = true
[]