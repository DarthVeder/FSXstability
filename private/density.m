function rho = density(h,unit)
%DENSITY ISA atmosphere density up to 32 km
%   Model from Eshelby "Aircraft Performance: Theory and Practice" pag. 274
%   App. C.
%   Input: 
%       h : ft or m. See unit.
%       unit : either 'uk' or 'si'. By default 'si'.
%   Output: 
%       rho : kg/m^3 (default) or slugs/ft^3
%
% See pressure for an example

if nargin == 2 % 'uk' unit required as output and given as input
    h = h * 0.3042; % ft -> m
end

R = 287.05287; % Nm/kgK
rho = pressure(h)/ (R*temperature(h));

if nargin == 2 % 'uk' unit required as output and given as input
    rho = rho * 0.00194032; % kg/m^3 -> slug/ft^3
end

end
