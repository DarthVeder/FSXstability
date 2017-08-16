function a = asound(h, unit)
%ASOUND ISA atmosphere sound speed up to 32 km
%   Model from Eshelby "Aircraft Performance: Theory and Practice" pag. 274
%   App. C.
%   in: h (ft or m)
%       unit, either 'uk' or 'si'. By default 'si'.
%   out: sound speed kt (default) or m/s

if nargin == 2 % 'uk' unit required as output and given as input
    h = h * 0.3042; % m
end

R = 287.05287; % Nm/kgK
gamma = 1.4;
a = sqrt( gamma*R*temperature(h) );

if nargin == 2 % 'uk' unit required as output and given as input
    a = a * 1.94384; % kt
end

end

