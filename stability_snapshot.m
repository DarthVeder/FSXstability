% This m file finds the aft and forward cg limit

clear
clc

% Loading aircraft data
[file, file_path] = uigetfile('','Load aircraft data')
run( strcat(file_path,file) )
addpath(file_path)

% Aircraft required configuration
% Loading aircraft data
[file, file_path] = uigetfile('','Load aircraft configuration',file_path)
run( strcat(file_path,file) )
disp('Current cofiguration:')
disp(config)

% station_load = weight, x, y, z (lb, ft, ft, ft)
[file, file_path] = uigetfile('','Station loads',file_path)
run( strcat(file_path,file) )
disp(sprintf('Current CG position (x,y,z) (ft):'))
disp(acft.xCG)
disp( 'Current weight (lb): ' )
disp( sprintf('%8.0f',(acft.W)) )
disp(sprintf('ACTUAL WEIGHT XCG/MAC: %4.2f%%',percentX(acft.xCG(1), acft)*100));

% Finding xcg forward and aft position limits based on gear configuration
B = (nlg - mlg);
Ma = 0.08 * B; % From Rymer
Mf = 0.18 * B; % From Rymer
Mf_c = percentX(Ma + mlg ,acft);
Ma_c = percentX(Mf + mlg , acft);
disp( sprintf('XCG gear limits: from %4.2f%% to %4.2f%%',Ma_c*100, Mf_c*100) )

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


