function F = levelEquations(x, acft, config)
%Steady flight level equations. 
%   Three equations system for steady level flight as described in
%   Guillaume. 
%   in: x(1) = alpha_deg [degrees]
%       x(2) = Thrust [lb] or v (kt) (*)
%       x(3) = detr [degrees]
%       solveT  = true or false. Controls which variable in (*) is solved
%   out: F = [CFx, CFz, CMtotal]

% Flight data
W     = acft.W; % lb
h     = config.h; % ft
teta  = config.teta_deg/180*pi; % pitch radiants
rho_  = density(h,'uk');
p     = pressure(h,'uk');
gamma = 1.4;

% Arms
mac = acft.mac;
dCGlonAC   = -acft.xACw       + acft.xCG(1) ;
dCGvertVMO = -acft.zVMO       + acft.xCG(3);
dEngvertCG = -acft.xEngine(3) + acft.xCG(3); % vertical offset of the engine in ft from the current CG

% Assigning solver variables
alpha_deg = x(1);
alpha = alpha_deg/180*pi;
if config.solveT
    M = config.kv/asound(h,'uk');
    thrust = x(2);
else
    M = x(2)/asound(h,'uk');
    thrust = acft.static_thrust;
end
detr_deg = x(3);
detr = detr_deg/180*pi;

% Auxiliary flight variables
q = 0.5*gamma*p*M^2;

% Lift OK
CLa = R404(alpha);
CLdf = acft.CL_df*(config.f_deg/180*pi)*acft.lift_scalar;
CLawf = (CLa+CLdf)*R401(M)*acft.cruise_lift_scalar;
CLih = acft.CL_h*(acft.htail_incidence/180*pi);
CLtotal = CLawf + CLih;

% Drag OK
CDgear = acft.CD_dg*config.gear_down;
CD0 = (acft.CD_0 + R430(M))*acft.parasite_drag_scalar;
k = 1./(acft.AR*acft.oswald_efficiency_factor*pi);
CL_lin = acft.dCLlindalp * (alpha_deg - acft.alpha0_deg)/57.3 + CLdf;
CDi = k*CL_lin^2*acft.induced_drag_scalar;
CDdf = acft.CD_df*(config.f_deg/180*pi)*acft.drag_scalar;
CDwf = CD0 + CDi + CDdf;
CDtotal = CDwf + CDgear;

% Total forces in x and z directions:
% ( Corrected equations )
CFx = - CDtotal - W*sin(teta)/(q*acft.wing_area) ...
    + acft.neng*thrust/(q*acft.wing_area);
CFz = -CLtotal + W*cos(teta)/(q*acft.wing_area);

% Pitch equation
CMa0  = acft.Cm0 + R433(M);
CMa   = R473(alpha);
CMdf  = acft.Cm_df*(config.f_deg/180*pi)*acft.pitch_scalar;
CMawf =  CMa + CMdf ...
      + dCGlonAC/mac * ( CLawf*cos(alpha) + CDwf*sin(alpha) ) ...
      + dCGvertVMO/mac * ( -CLawf*sin(alpha) + CDwf*cos(alpha) ); 
CMih  = ( acft.Cm_h + R423(M) )*(acft.htail_incidence/180*pi)*R537(alpha_deg) ...
      + dCGlonAC/mac * ( CLih*cos(alpha) ) ...
      + dCGvertVMO/mac * ( -CLih*sin(alpha) );

CMdetr = acft.Cm_dt* detr *R536(alpha_deg)*R1525(q)*acft.elevator_trim_effectiveness;
CMgear = acft.Cm_dg * config.gear_down ...
       + dCGlonAC/mac * CDgear*sin(alpha) ...
       + dCGvertVMO/mac * CDgear*cos(alpha);
CMaero = CMa0 + CMawf + CMih + CMdetr + CMgear;

CMpropulsion = ( acft.neng*thrust/(q*acft.wing_area) ) * (dEngvertCG/mac);
CMtotal = -CMaero + CMpropulsion;

F(1) = CFx;
F(2) = CFz;
F(3) = CMtotal;

end

