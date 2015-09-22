[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 20
  ny = 20
  xmin = -10
  xmax = 10
  ymin = -10
  ymax = 10
[]

[Variables]
  [./cv]
  [../]
  [./wv]
  [../]
  [./ci]
  [../]
  [./wi]
  [../]
  [./e]
  [../]
[]

[AuxVariables]
  [./total_en]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  [./IC_c]
    # int_width = 0.2
    int_width = 1.0
    x1 = 0.0
    y1 = 0.0
    radius = 5.0
    outvalue = 0.122
    variable = cv
    invalue = 0.999
    type = SmoothCircleIC
  [../]
  [./IC_e]
    int_width = 1.0
    x1 = 0
    y1 = 0
    radius = 5.0
    outvalue = 0.0
    variable = e
    invalue = 1.0
    type = SmoothCircleIC
  [../]
  [./IC_ci]
    # int_width = 0.2
    int_width = 1.0
    x1 = 0.0
    y1 = 0.0
    radius = 5.0
    outvalue = 6.9e-4
    variable = ci
    invalue = 1e-6
    type = SmoothCircleIC
  [../]
  #[./rnd_cv]
  #  variable = cv
  #  type = RandomIC
  #  max = 0.999
  #  min = 0.001
  ##[../]
  #[./rnd_e]
  #  variable = e
  #  type = RandomIC
  #  max = 1
  #  min = 0
  #[../]
  #[./rnd_ci]
  #  variable = ci
  #  type = RandomIC
  #  max = 0.999
  #  min = 0.001
  #[../]
  #[./const_e]
  #  variable = e
  #  value = 0.0
  #  type = ConstantIC
  #  block = 0
  #[../]
  #[./IC_gr0]
  #  y2 = 64
  #  x1 = -64
  #  y1 = -64
  #  inside = 1.0000
  #  grain_side = left
  #  x2 = 0
  #  variable = gr0
  #  int_width = 2
  #  type = BicrystalIC
  #  block = 0
  #[../]
  #[./IC_gr1]
  #  y2 = 64
  #  x1 = 0
  #  y1 = -64
  #  inside = 1.0
  #  grain_side = right
  #  x2 = 64
  #  variable = gr1
  #  int_width = 2
  #  type = BicrystalIC
  #  block = 0
  #[../]
  #[./ci_ic]
  #  variable = ci
  #  value = 6.9e-4
  #  type = ConstantIC
  #  block = 0
  #[../]
[]

[Kernels]
  [./c_dot]
    type = CoupledTimeDerivative
    variable = wv
    v = cv
  [../]
  [./c_res]
    type = SplitCHParsed
    variable = cv
    f_name = F
    kappa_name = kappa_c
    w = wv
    args = 'e ci'
  [../]
  [./w_res]
    type = SplitCHWRes
    variable = wv
    mob_name = Mv
    args = 'e ci'
  [../]
  [./AC_bulk]
    type = ACParsed
    variable = e
    f_name = F
    args = 'cv ci'
  [../]
  [./AC_int]
    type = ACInterface
    variable = e
  [../]
  [./e_dot]
    type = TimeDerivative
    variable = e
  [../]
  [./ci_dot]
    type = CoupledTimeDerivative
    variable = wi
    v = ci
  [../]
  [./ci_res]
    type = SplitCHParsed
    variable = ci
    f_name = F
    args = 'cv e'
    kappa_name = kappa_c
    w = wi
  [../]
  [./wi_res]
    type = SplitCHWRes
    variable = wi
    mob_name = Mi
    args = 'cv e'
  [../]
  [./cv_recomb]
    type = VacancyRecombination
    variable = cv
    ci = ci
    Rs = 10.0
    eta = e
  [../]
  [./ci_recomb]
    type = VacancyRecombination
    variable = ci
    ci = cv
    Rs = 10.0
    eta = e
  [../]
  #[./ints_noise]
  #  type = ConservedLangevinNoise
  #  variable = ci
  #  noise = noise
  #  amplitude = 0.2
  #  block = 0
  #[../]
  #[./e_noise]
  #  type = ConservedLangevinNoise
  #  variable = e
  #  noise = noise
  #  amplitude = 0.25
  #  block = 0
  [../]
[]

[AuxKernels]
  [./total_en]
    type = TotalFreeEnergy
    variable = total_en
    interfacial_vars = 'cv e'
    kappa_names = 'kappa_c kappa_op'
  [../]
[]

[Materials]
  [./Energy_matrix]
    type = DerivativeParsedMaterial
    block = 0
    function = '(Ef*cv+Ei*ci+kbT*(cv*log(cv)+ci*log(ci)+(1.0-cv)*log(1.0-cv)+(1.0-ci)*log(1.0-ci)))'
    args = 'cv ci'
    f_name = fi
    tol_names = 'cv ci '
    tol_values = '1e-6 1e-6'
    constant_names = 'Ef kbT Ei'
    constant_expressions = '1.0 0.11 1.0'
    derivative_order = 2
    outputs = exodus
  [../]
  [./Vacancy_en]
    type = DerivativeParsedMaterial
    block = 0
    function = (cv-1.0)*(cv-1.0)+ci*ci
    f_name = fv
    args = 'cv ci'
    derivative_order = 2
  [../]
  [./switching_function]
    type = SwitchingFunctionMaterial
    block = 0
    eta = e
  [../]
  [./barrier_function]
    type = BarrierFunctionMaterial
    block = 0
    eta = e
  [../]
  [./free_en]
    type = DerivativeTwoPhaseMaterial
    block = 0
    args = 'cv ci'
    derivative_order = 2
    eta = e
    fa_name = fi
    fb_name = fv
  [../]
  [./Mobility_cv]
    type = DerivativeParsedMaterial
    block = 0
    function = 'Dv*cv/kbT'
    args = 'cv'
    constant_names = 'Dv kbT '
    constant_expressions = '1.0e-6 0.11 '
    derivative_order = 2
    f_name = Mv
    outputs = exodus
  [../]
  [./Mobility_ci]
    type = DerivativeParsedMaterial
    block = 0
    function = 'Dv*ci/kbT'
    args = 'ci'
    constant_names = 'Dv kbT '
    constant_expressions = '1.0e-6 0.11 '
    derivative_order = 2
    f_name = Mi
    outputs = exodus
  [../]
  [./kappa_c]
    type = ParsedMaterial
    block = 0
    f_name = kappa_c
    material_property_names = 'Mv'
    function = 3/4*Mv
  [../]
  [./L]
    type = ParsedMaterial
    block = 0
    f_name = L
    material_property_names = 'Mv'
    function = 4/3*Mv
  [../]
  [./kappa_op]
    type = ParsedMaterial
    block = 0
    f_name = kappa_op
    material_property_names = 'Mv'
    function = 3/4*Mv
  [../]
[]

[Postprocessors]
  [./ElementInt_cv]
    type = ElementIntegralVariablePostprocessor
    variable = cv
  [../]
  [./Element_int_eta]
    type = ElementIntegralVariablePostprocessor
    variable = e
  [../]
  [./total_en]
    type = ElementIntegralVariablePostprocessor
    variable = total_en
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    off_diag_column = 'cv wv ci wi e  cv e  ci ci cv'
    off_diag_row =    'wv cv wi ci cv e  ci e  cv ci'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  end_time = 20.0
  l_max_its = 20
  nl_max_its = 20
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm         31   preonly   lu      1'
  dt = 0.005
  l_tol = 1.0e-3
  nl_rel_tol = 1.0e-8
  #nl_abs_tol = 1.0e-6
  [./Adaptivity]
    refine_fraction = 0.7
    coarsen_fraction = 0.1
    max_h_level = 2
    initial_adaptivity = 1
  [../]
  #[./TimeStepper]
  #  type = IterationAdaptiveDT
  #  dt = 0.01
  #[../]
[]

[Outputs]
  # print_linear_residuals = true
  exodus = true
  output_on = 'timestep_end initial'
  csv = true
  gnuplot = true
  #interval = 100
  [./console]
    type = Console
    perf_log = true
    output_on = 'timestep_end failed nonlinear linear'
  [../]
[]
