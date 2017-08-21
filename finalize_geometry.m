% finalize_geometry Computes data given the geometry and station loads.

% Computing mac and lemac from Rymer pagg 155-156
acft.dCLlindalp = ( R404(10/180.0*pi) - R404(0) ) / (10/180.0*pi); % 1/rad
acft.dCMlindalp = ( R473(10/180.0*pi) - R473(0) ) / (10/180.0*pi); % 1/rad
acft.AR = acft.wing_span^2/acft.wing_area;
disp(sprintf('AR : %4.2f',acft.AR))
lam = 2*acft.wing_area/(acft.wing_span*acft.wing_root_chord)-1;
acft.lam = lam;
acft.mac = 2./3.*acft.wing_root_chord * (1+lam+lam^2)/(1+lam); % ft
disp(sprintf('MAC : %4.2f ft',acft.mac))
y_r = acft.wing_span/6. * (1+2*lam)/(1+lam); % ft
x_r = y_r *tan(acft.wing_sweep/180.*pi); %ft
acft.lemac = acft.wing_pos_apex_lon - x_r; 
xew_c = percentX(acft.empty_weight_CG_position(1), acft);
% Estimated wing aerodynamic center
%acft.xACw = acft.lemac-acft.mac/4.0;
xACw = acft.reference_datum_position(1) - acft.dCMlindalp/acft.dCLlindalp*acft.mac;
%xACw =0.25 + acft.AR/6.0*(1+2.0*lambda)/(1+lambda)*tan(acft.wing_sweep/180*pi)*acft.mac; /* alternative formulation */
acft.xACw = [xACw, 0, 0]
% Finding xcg forward and aft position limits based on gear configuration
nlg = acft.point_0(1);
mlg = acft.point_1(1);
B = (nlg - mlg);
Ma = 0.08 * B; % From Rymer
Mf = 0.18 * B; % From Rymer
Mf_c = percentX(Ma + mlg ,acft);
Ma_c = percentX(Mf + mlg , acft);
disp( sprintf('XCG gear limits: from %4.2f%% to %4.2f%%',Ma_c*100, Mf_c*100) )
acft.xcg_fwd = Ma_c*100; % ft
acft.xcg_aft = Mf_c*100; % ft
