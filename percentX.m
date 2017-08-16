function val = percentX(x, acft)
%percentX converts a position along the aircraft longitudinal axis, in percent.
%   in: x ft 
%       acft the aicraft data
%   out: x_c adimensional

val = (acft.lemac - x)/acft.mac;

end

