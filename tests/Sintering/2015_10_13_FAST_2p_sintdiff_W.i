[GlobalParams]
  var_name_base = gr
  op_num = 2.0
  use_displaced_mesh = true
  outputs = exodus
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 70
  ny = 60
  nz = 0
  xmin = 0.0
  xmax = 140.0
  ymin = 0.0
  ymax = 120.0
  zmax = 0
  elem_type = QUAD4
[]

[Variables]
  [./c]
  [../]
  [./w]
  [../]
  [./PolycrystalVariables]
  [../]
[]

[AuxVariables]
  [./bnds]
  [../]
  [./total_en]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    off_diag_column = 'c w c   c   gr0 gr1'
    off_diag_row    = 'w c gr0 gr1 c   c'
  [../]
[]

[Kernels]
  [./cres]
    type = SplitCHParsed
    variable = c
    kappa_name = kappa_c
    w = w
    f_name = F
    args = 'gr0  gr1'
  [../]
  [./wres]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  [./time]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
  [./PolycrystalSinteringKernel]
    c = c
    mob_name = M
  [../]
[]

[AuxKernels]
  [./bnds]
    type = BndsCalcAux
    variable = bnds
    v = 'gr0 gr1 '
  [../]
  [./Total_en]
    type = TotalFreeEnergy
    variable = total_en
    kappa_names = 'kappa_c kappa_op kappa_op'
    interfacial_vars = 'c  gr0 gr1'
  [../]
[]

[BCs]
  [./Periodic]
    [./All]
      auto_direction = 'x y'
      variable = 'c w gr0 gr1'
    [../]
  [../]
[]

[Materials]
  [./free_energy]
    type = SinteringFreeEnergy
    block = 0
    c = c
    v = 'gr0 gr1'
    f_name = F
    derivative_order = 2
    outputs = console
  [../]
  #[./CH_mat]
  #  type = PFDiffusionGrowth
  #  block = 0
  #  rho = c
  #  v = 'gr0 gr1'
  #  outputs = console
  #[../]
  [./CH_mat]
    type = SinteringDiffusion
    block = 0
    outputs = console
    Qv = 2.4
    Qs = 3.14
    GBMobility = 5.13e-20
    surface_energy = 58.23e18
    rho = c
    Dsurf0 = 4e-4
    Qgb = 4.143
    Q = 4.143
    T = 1200
    GB_energy = 42.85e18
    Dgb0 = 5.0e-5
    Dvol0 = 4e-6
    int_width = 2
    v = 'gr0 gr1'
    #length_scale = 1.0
    time_scale = 1.0
  [../]
  [./constant_mat]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'A      B   kappa_op kappa_c'
    prop_values = '4.654 0.5 1.5      2.038'
  [../]
[]

[Postprocessors]
  [./mat_D]
    type = ElementIntegralMaterialProperty
    mat_prop = D
  [../]
  [./elem_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
  [./elem_bnds]
    type = ElementIntegralVariablePostprocessor
    variable = bnds
  [../]
[]

[VectorPostprocessors]
  [./neck]
    type = LineValueSampler
    variable = 'c bnds'
    start_point = '20.0 0.0 0.0'
    end_point = '20.0 20.0 0.0'
    sort_by = id
    num_points = 40
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = BDF2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  l_max_its = 20
  nl_max_its = 20
  l_tol = 1.0e-4
  nl_rel_tol = 1.0e-6
  nl_abs_tol = 1.0e-10
  end_time = 30.0
  dt = 0.005
  [./Adaptivity]
    refine_fraction = 0.7
    coarsen_fraction = 0.1
    max_h_level = 2
    initial_adaptivity = 1
  [../]
  #[./TimeStepper]
  #  type = IterationAdaptiveDT
  #  dt = 0.01
  #  growth_factor = 1.5
  #[../]
[]

[Outputs]
  exodus = true
  output_on = 'initial timestep_end'
  print_linear_residuals = true
  csv = true
  interval = 100
  [./console]
    type = Console
    perf_log = true
    output_on = 'initial timestep_end failed nonlinear linear'
  [../]
[]

[ICs]
  [./ic_gr1]
    int_width = 2.0
    x1 = 25.0
    y1 = 10.0
    radius = 7.0
    outvalue = 0.0
    variable = gr1
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./multip]
    x_positions = '10.0 25.0'
    int_width = 2.0
    z_positions = '0 0'
    y_positions = '10.0 10.0 '
    radii = '7.0 7.0'
    3D_spheres = false
    outvalue = 0.001
    variable = c
    invalue = 0.999
    type = SpecifiedSmoothCircleIC
    block = 0
  [../]
  [./ic_gr0]
    int_width = 2.0
    x1 = 10.0
    y1 = 10.0
    radius = 7.0
    outvalue = 0.0
    variable = gr0
    invalue = 1.0
    type = SmoothCircleIC
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
