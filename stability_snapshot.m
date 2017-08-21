2% This m file allows a snapshot computation for detr given a specifi load.
% In the user directory there must be three files with the following structure:
% 1) aicraft_data : it contains all the main geometric and engine(s) data and the coordinates of FSX VMO and wing AC
% 2) aircraft_configuration
%       config.gear_down : gear up (0) or down (1)
%       config.f_deg :  deg flaps for current configuration
%       config.teta_deg :  ramp angle deg. "0" for horizontal flight
%       config.h :  ft aircraft height
%       config.kv :  kt aircraft speed KTAS
%       config.solveT :  bool. True for finding thrust, false for findin v (tas) 
%       acft.xVMO : vector with VMO coordinates [xVMO, yVMO, zVMO]
% 3) station_load : the aircraft section 'station_loads' to simulate different loading conditions.
% Both files 1) and 3) can be generated ether by hand or using the preproc tool readFSXAircraft.py.
% One needs also to insert in the same directory of the three files above, the following functions:
%   R401
%   R404
%   R423
%   R430
%   R433
%   R473
%   R536 /* if missing set to 1 */
%   R537 /* if missing set to 1 */
%   R1525
%
%   Output:
%       a : coefficients for detr[deg] = f(W,xcg/c) approximation. The
%           approximate function f(W,xcg/c) is given as:
%           detr_deg = a(1)*(W/Wmax)^3 + a(2)*(W/Wmax)^2 + a(3)*(W/Wmax) + a(4) + a(5)*xcg_c/100;
%       detrp : matrix nrow by ncol, where nrow is the number of xcg/c
%               points and ncol is the number of weight points used.

clear
clc

% Loading aircraft data
[file, file_path] = uigetfile('','Load aircraft data')
run( strcat(file_path,file) )
addpath(file_path)
% Computing useful parameters from geometry data
finalize_geometry;

% station_load
prompt = 'Do you want to specify xCG(ft) and W (lb)? y/n [n]: ';
str = input(prompt,'s');
if isempty(str)
    str = 'n';
end
if str == 'y' || str == 'Y'
    data = inputdlg({'xCG coords x,y,z separated by space', 'Weight (lb)'},'Configuration')
    acft.xCG = str2num(cell2mat(data(1)));
    acft.W = str2num(cell2mat(data(2)));
else
    [file, file_path] = uigetfile('','Station loads',file_path)
    run( strcat(file_path,file) )    
end


if str == 'n' || str == 'N'
    [acft.xCG, acft.W] = computeCG(acft.empty_weight, acft.empty_weight_CG_position, acft.station_load, acft.fuel); % return in [ft, lb]
end

disp(sprintf('Current CG position (x,y,z) (ft):'))
disp(acft.xCG)
disp( 'Current weight (lb): ' )
disp( sprintf('%8.0f',(acft.W)) )
disp(sprintf('ACTUAL WEIGHT XCG/MAC: %4.2f%%',percentX(acft.xCG(1), acft)*100));
disp( sprintf('XCG gear limits: from %4.2f%% to %4.2f%%',acft.xcg_fwd, acft.xcg_aft) )

% Loading aircraft configuration
[file, file_path] = uigetfile('','Load aircraft configuration',file_path)
run( strcat(file_path,file) )
disp('Current cofiguration:')
disp(config)

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


