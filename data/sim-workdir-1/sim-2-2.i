#-------------------------------------------------------------------------
# pyvale: gmsh,3Dstc,1mat,thermal,steady,
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
#_* MOOSEHERDER VARIABLES - START

# NOTE: only used for transient solves
#endTime= 1
#timeStep = 1

# Thermal Loads/BCs
coolantTemp = 100 # degC
heatTransCoeff = 125000 # W.m^-2.K^-1
surfHeatFlux = 5000000 # W.m^-2

# Material Properties: Pure (OFHC) Copper at 250degC
cuDensity = 8829 # kg.m^-3
cuThermCond = 384 # W.m^-1.K^-1
cuSpecHeat = 406 # J.kg^-1.K^-1

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