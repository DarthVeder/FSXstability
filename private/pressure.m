function P = pressure(h, unit)
%PRESSURE ISA atmosphere pressure up to 32 km
%   Model from Eshelby "Aircraft Performance: Theory and Practice" pag. 274
%   App. C.
%   in: h (ft or m)
%       unit, either 'uk' or 'si'. Default 'si'

if nargin == 2 % 'uk' unit required as output and given as input
    h = h * 0.3042; % m
end

P = 0;
if h <= 11000
    P = 101325 * ( 1 - 0.000022558*h )^5.25588;
elseif h <= 20000
    P = 22632 * exp(-0.000157688*(h-11000));
elseif h <= 32000
    P = 5474.9 * ( 1 + 0.000004616*(h-20000))^(-34.1632);
end

if nargin == 2 % 'uk' unit required as output and given as input
    P = P * 0.021; % psf
end

end

