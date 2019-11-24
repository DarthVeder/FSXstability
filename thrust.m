function [net_thrust, gross_thrust, ram_drag] = thrust(M, h_ft, acft, config)
%thrust() Computes FSX TOTAL jet thrust at a specific Mach number and heigh (ft). NO VECTORS IN INPUT.
% 	   Always assume CN1 = 98%
%   The equations used are for standard FSX jet thrust computation:
%	gross_thrust = acft.static_thrust*R1506(M,h)*delta_2
%	ram_drag = v_ft_s/g_ft_s * acft.intake_area*R1507(M,h)*delta_2/sqrt(teta_2)
%   Input: 
%       M : Mach number. Single value.
%       h_ft : heigh in ft. Single value.
%       acft : acft data
%       config : aicraft config. NOT used, just for future development 
%   Output:
%       net_thrust 
%	gross_thrust
%	ram_drag : all in lbf. net_thrust = gross_thrust-ram_drag  

% Engine data
CN1 = 98.0;

% Flight data
temp_SL  = density(0,'uk'); % slug/ft^3
p_SL    = pressure(0,'uk'); % psf
gamma = 1.4;

temp_h  = density(h_ft,'uk'); % slug/ft^3
p_h    = pressure(h_ft,'uk'); % psf
a_h = asound(h_ft,'uk');
kv = a_h*M;
v_ft_s = kv*1.68781;
g_ft__s2 = 32.185039;

teta = temp_h / temp_SL;
fM = 1+0.2*M^2
delta = p_h / p_SL;

gross_thrust = acft.static_thrust * R1506(M,CN1) * delta_2;

gross_thrust = V_ft_s/g_ft_s2 * acft.intake_area * R1507(M,CN1) * delta_2/sqrt(teta_2);

net_thrust = acft.neng * (gross_thrust - ram_drag);

end

