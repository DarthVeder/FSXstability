function rho = density(h,unit)
%DENSITY ISA atmosphere density up to 32 km
%   Model from Eshelby "Aircraft Performance: Theory and Practice" pag. 274
%   App. C.
%   in: h (ft or m)
%       unit, either 'uk' or 'si'. By default 'si'.
%   out: density kg/m^3 (default) or slugs/ft^3

if nargin == 2 % 'uk' unit required as output and given as input
    h = h * 0.3042; % m
end

R = 287.05287; % Nm/kgK
rho = pressure(h)/ (R*temperature(h));

if nargin == 2 % 'uk' unit required as output and given as input
    rho = rho * 0.00194032; % psf
end

end