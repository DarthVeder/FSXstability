% This m file finds elevator trim - xcg relationship for diffrent weight and configuration.
% It produces also a best fit curve to use in ad-hoc xml gauges.
% It solves for either [alpha_deg, T lb, detr_deg] (true) or [alpha_deg, v kt, detr_deg] (false), using 
% bool config.solveT variable set to true/false.
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
%%%%%%%%%%%%%%%%%%%%%%%%%
%% START INPUT DATA
%%%%%%%%%%%%%%%%%%%%%%%%%
% Loading aircraft data
[file, file_path] = uigetfile('','Load aircraft data')
run( strcat(file_path,file) )
addpath(file_path)

% station_load 
[file, file_path] = uigetfile('','Station loads',file_path)
run( strcat(file_path,file) )

% Compute useful parameters given the geometry
finalize_geometry;

% Aircraft configuration
[file, file_path] = uigetfile('','Aircraft configuration',file_path)
run( strcat(file_path,file) )
disp('Current cofiguration:')
disp(config)

% Setting up mass vectors and xcg_c
Wmax = acft.max_gross_weight;
W = [acft.empty_weight:5000:acft.max_gross_weight];
xcg_c = linspace(acft.xcg_fwd,acft.xcg_aft,20); % xcg/c range (%)
%%%%%%%%%%%%%%%%%%%%%%%%
% END INPUT DATA
%%%%%%%%%%%%%%%%%%%%%%%%
disp( sprintf('XCG gear limits: from %4.2f%% to %4.2f%%',acft.xcg_fwd, acft.xcg_aft) )

% Solver options
options.MaxIter = 1200;
options.MaxFunEvals = 2600;
%options.Display = 'iter';
options.TolFun = 1.0e-8;

hold on;
n = 1;
% Loop to find elevator trim angle for different weights
for j=1:length(W)    
    acft.W = W(j);    
    title{j} = num2str(W(j));
    for i=1:length(xcg_c)        
        acft.xCG = [acft.lemac - xcg_c(i)/100* acft.mac, 0, 0];
        
        M(n,1) = (W(j)/Wmax)^3.0;
        M(n,2) = (W(j)/Wmax)^2.0;
        M(n,3) = (W(j)/Wmax);        
        M(n,4) = 1.0;
        M(n,5) = xcg_c(i)/100;        
        
        disp(sprintf('Current CG position (x,y,z) (ft):'))
        disp(acft.xCG)
        disp( 'Current weight (lb): ' )
        disp( sprintf('%8.0f',(acft.W)) )
        disp(sprintf('ACTUAL WEIGHT XCG: %4.2f%%',percentX(acft.xCG(1), acft)*100));

        % Solving routine:
        if config.solveT
            x0 = [0, acft.static_thrust*0.5, 0]; % alpha_deg, T lb, detr_deg
        else
            x0 = [0, 180, 0]; % alpha_deg, v kt, detr_deg
        end
        fun = @(x)levelEquations(x, acft, config);
        [x,FVAL,EXITFLAG] = fsolve(fun,x0,options);
        detr(n) = x(3); 
        detrp(i,j) = x(3);
        if config.solveT
            disp('Steady state solution (alpha deg, T lb, detr deg):')
        else
            disp('Steady state solution (alpha deg, v kt, detr deg):')
        end
        disp(sprintf('%16.2f',x))
        CF = levelEquations(x, acft, config);
        disp('Total forces and moments norm (CFx, CFz, CMtotal):')
        disp(norm(CF))        
        
        n = n + 1;
    end
    if j==1        
        plot(xcg_c,detrp(:,1),'b--')        
    else
        plot(xcg_c,detrp(:,j),'b-')
    end    
end
legend(title);
xlabel('xcg/c')
ylabel('\delta_{etr} (deg)')
hold off;

% Interpolation based on:
% detr_deg = a(1)*(W/Wmax)^3 + a(2)*(W/Wmax)^2 + a(3)*(W/Wmax) + a(4) + a(5)*xcg_c/100;
a = M\detr';
disp('Approximate detr-xcg_c function:')
disp(sprintf('detr(xcg)[deg] = %4.2f *(W/Wmax)^3 + %4.2f *(W/Wmax)^2 + %4.2f *(W/Wmax) + %4.2f + %4.2f *xcg_c/100',a(1),a(2),a(3),a(4),a(5)))


% To check if approximation is correct set the following data:
%xcg_ct = 45
%Wt = 170710 % lb
%detr_app_deg = a(1)*(Wt/Wmax)^3 + a(2)*(Wt/Wmax)^2 + a(3)*(Wt/Wmax) + a(4) + a(5) * (xcg_ct/100)




