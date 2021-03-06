[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  xmin = 0.0
  xmax = 10.0
  ymin = 0.0
  ymax = 10.0
  elem_type = QUAD4
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.9
  [../]
  [./w]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./rand]
    block = 0
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    off_diag_row = 'w c'
    off_diag_column = 'c w'
  [../]
[]

[Kernels]
  [./cres]
    type = SplitCHMath
    variable = c
    kappa_name = kappa_c
    w = w
  [../]
  [./wres]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]
  [./time]
    type = CoupledImplicitEuler
    variable = w
    v = c
  [../]
  [./conserved_langevin]
    type = ConservedLangevinNoise
    amplitude = 0.5
    variable = w
    noise = uniform_noise
  [../]
[]

[AuxKernels]
  [./rand]
    type = RandomVoidSourceAux
    variable = rand
    block = 0
  [../]
[]

[BCs]
  [./Periodic]
    [./all]
      variable = 'c w'
      auto_direction = 'x y'
    [../]
  [../]
[]

[Materials]
  [./constant]
    type = PFMobility
    block = 0
    mob = 1.0
    kappa = 2.0
  [../]
[]

[UserObjects]
  [./uniform_noise]
    type = ConservedUniformVoidSource
  [../]
[]

[Postprocessors]
  [./total_c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  [../]
[]

[Executioner]
  # Preconditioned JFNK (default)
  type = Transient
  scheme = BDF2
  solve_type = PJFNK
  petsc_options_iname = -pc_type
  petsc_options_value = lu
  l_max_its = 30
  l_tol = 1.0e-3
  nl_max_its = 30
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1.0e-10
  dt = 10.0
  num_steps = 4
[]

[Outputs]
  file_base = uniform_1
  output_initial = true
  exodus = true
  print_linear_residuals = true
  print_perf_log = true
  [./csv]
    type = CSV
    delimiter = ' '
  [../]
[]

