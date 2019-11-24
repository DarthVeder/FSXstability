% This m file finds elevator trim - xcg relationship for different weight and configurations.
% It produces also a best fit curve to use in ad-hoc xml gauges.
% It solves for either [alpha_deg, T lb, detr_deg] (true) or [alpha_deg, v kt, detr_deg] (false), using 
% bool config.solveT variable set to true/false.
% In the user directory there must be three files with the following structure:
% 1) aicraft data : it contains all the main geometric and engine(s) data
% obtained by preproc tool
% 2) aircraft_configuration
%       config.gear_down : gear up (0) or down (1)
%       config.f_deg :  deg flaps for current configuration
%       config.teta_deg :  ramp angle deg. "0" for horizontal flight
%       config.h :  ft aircraft height
%       config.kv :  kt aircraft speed KTAS
%       config.solveT :  bool. True for finding thrust, false for findin v (tas) 
%       acft.xVMO : vector with VMO coordinates [xVMO, yVMO, zVMO]
% 3) station_load : the aircraft section 'station_loads' to simulate different loading conditions.
%                   Generated with preproc tool.
%   Output:
%       a : coefficients for detr[deg] = f(W,xcg/c) approximation. The
%           approximate function f(W,xcg/c) is given as:
%           detr_deg = a(1)*(W/Wmax)^3 + a(2)*(W/Wmax)^2 + a(3)*(W/Wmax) + a(4) + a(5)*xcg_c/100;
%       detrp : matrix nrow by ncol, where nrow is the number of xcg/c
%               points (20) and ncol is the number of weight points used (from empty weight to mtom every 5000 lb).

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
nWsteps = 3;
dW = (acft.max_gross_weight - acft.empty_weight) / (nWsteps-1);
W = [acft.empty_weight:dW:acft.max_gross_weight];
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

% Check de trim is between maximun and minimum value. If it is outside, NaN
% is used instead of the value.

% Interpolation based on:
% detr_deg = a(1)*(W/Wmax)^3 + a(2)*(W/Wmax)^2 + a(3)*(W/Wmax) + a(4) + a(5)*xcg_c/100;
a = M\detr';
disp('Approximate detr-xcg_c function:')
disp(sprintf('detr(xcg)[deg] = %4.2f *(W/Wmax)^3 + %4.2f *(W/Wmax)^2 + %4.2f *(W/Wmax) + %4.2f + %4.2f *xcg_c/100',a(1),a(2),a(3),a(4),a(5)))

n = size(detrp);
% xcg_c_limit(i,k) store for weight W(j) the xcg_c min in xcg_c_limit(i,k=1) and the
% xcg_c max in xcg_c_limit(i,k=2)

% Initializing for min and max search
for j=1:n(2)
    xcg_c_limit(j,1) = 1e3;
    xcg_c_limit(j,2) = -1e3;
end
for i=1:n(1) % loop on all xcg_c positions
    for j=1:n(2) % loop on all weights
        if abs(detrp(i,j)) > acft.elevator_trim_limit
            detrp(i,j) = NaN;
        else
            xcg_c_limit(j,1) = min(xcg_c(i), xcg_c_limit(j,1));
            xcg_c_limit(j,2) = max(xcg_c(i), xcg_c_limit(j,2));
        end
    end
end

    % Plot Weight versus xcg_c
figure;
xlabel('W/1000 (lb)')
ylabel('xcg/c (%)')
plot(xcg_c_limit(:,1), W./1000, 'o-', xcg_c_limit(:,2), W./1000, '^-')
legend('min', 'max')

format shortg
disp('CG (%) range')
disp('W(lb) xcg/c (%) min max')
disp([W',xcg_c_limit])
format


% To check if approximation is correct set the following data:
%xcg_ct = 45
%Wt = 170710 % lb
%detr_app_deg = a(1)*(Wt/Wmax)^3 + a(2)*(Wt/Wmax)^2 + a(3)*(Wt/Wmax) + a(4) + a(5) * (xcg_ct/100)




