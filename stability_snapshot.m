% This m file allows a snapshot computation for detr given a specifi load.
% In the user directory there must be three files with the following structure:
% 1) aicraft_data
%       /* Geometry from aircraft.cfg */
%       acft.wing_area : ft^2
%       acft.wing_span :  ft
%       acft.wing_root_chord : ft
%       acft.wing_sweep :  deg
%       acft.oswald_efficiency_factor :  1
%       wing_pos_apex_lon :  ft
%       elevator_trim_limit :  deg
%       acft.xEngine : [x y z]  ft [y: can be positive or negative. No influence]
%       acft.reference_datum_position : [x y z] ft
%       acft.neng :  Number of engines
%       acft.static_thrust :   lb per engine
%       acft.cruise_lift_scalar 
%       acft.parasite_drag_scalar 
%       acft.induced_drag_scalar
%       acft.pitch_stability
%       yaw_stability
%       acft.elevator_trim_effectiveness
%       rudder_effectiveness
%       acft.htail_incidence deg
%       acft.empty_weight_CG_position : [x y z] ft
%       acft.empty_weight :  lb
%       acft.max_gross_weight :  lb
%       nlg :  ft nose landing gear longitudinal position
%       mlg :  ft main landing gear longitudinal position
%       deltaf : [0 1 2 5 10 15 25 30 40] positions in degrees
%       acft.lift_scalar
%       acft.drag_scalar
%       acft.pitch_scalar
%       /* Aerodynamic data from .air file */
%       acft.alpha0_deg = TBL404(CL=0)/pi*180; % rad -> degrees 
%       acft.CD_0
%       acft.CD_df
%       acft.CD_dg
%       acft.CL_h
%       acft.CL_df
%       acft.Cm0
%       acft.Cm_h
%       acft.Cm_dt /* thrust, not trim!! */
%       acft.Cm_df
%       acft.Cm_dg
%       /* Arms. Visual Point */
%       acft.xVMO : ft
%       acft.zVMO : ft
% 2) aircraft_configuration
%       config.gear_down : gear up (0) or down (1)
%       config.f_deg :  deg flaps for current configuration
%       config.teta_deg :  ramp angle deg. "0" for horizontal flight
%       config.h :  ft aircraft height
%       config.kv :  kt aircraft speed KTAS
%       config.solveT :  bool. True for finding thrust, false for findin v (tas) 
% 3) station_load
%       station_load :  [weight_i (lb),  xi (ft), yi (ft), zi (ft)  ;];
%       fuel : [xi (ft),   yi (ft), zi(ft), fuel_weight (USG);];
% One needs also to insert in the same directory of the three files abov, the folling functions:
%   R401
%   R404
%   R423
%   R430
%   R433
%   R473
%   R536 /* if missing set to 1 */
%   R537 /* if missing set to 1 */
%   R1525

clear
clc

% Loading aircraft data
[file, file_path] = uigetfile('','Load aircraft data')
run( strcat(file_path,file) )
addpath(file_path)

% Aircraft required configuration
% Loading aircraft configuration
[file, file_path] = uigetfile('','Load aircraft configuration',file_path)
run( strcat(file_path,file) )
disp('Current cofiguration:')
disp(config)

% Computing useful parameters from geometry data
finalize_geometry;

% station_load 
[file, file_path] = uigetfile('','Station loads',file_path)
run( strcat(file_path,file) )
[acft.xCG, acft.W] = computeCG(acft.empty_weight, acft.empty_weight_CG_position, station_load, fuel); % return in [ft, lb]
disp(sprintf('Current CG position (x,y,z) (ft):'))
disp(acft.xCG)
disp( 'Current weight (lb): ' )
disp( sprintf('%8.0f',(acft.W)) )
disp(sprintf('ACTUAL WEIGHT XCG/MAC: %4.2f%%',percentX(acft.xCG(1), acft)*100));
disp( sprintf('XCG gear limits: from %4.2f%% to %4.2f%%',acft.xcg_fwd, acft.xcg_aft) )

% Solving routine:
if config.solveT
    x0 = [0, acft.static_thrust*0.5, 0]; % alpha_deg, T lb, detr_deg
else
    x0 = [0, 180, 0]; % alpha_deg, v kt, detr_deg
end
fun = @(x)levelEquations(x, acft, config);
options.MaxIter = 1200;
options.MaxFunEvals = 2600;
options.Display = 'iter';
options.TolFun = 1.0e-8;
[x,FVAL,EXITFLAG] = fsolve(fun,x0,options);
if config.solveT
    disp('Steady state solution (alpha deg, T lb, detr deg):')
else
    disp('Steady state solution (alpha deg, v kt, detr deg):')
end
disp(sprintf('%16.2f',x))
CF = levelEquations(x, acft, config);
disp('Total forces and moments (CFx, CFz, CMtotal):')
disp(CF)


