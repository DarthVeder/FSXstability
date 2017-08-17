function a = asound(h, unit)
%ASOUND ISA atmosphere sound speed up to 32 km
%   Model from Eshelby "Aircraft Performance: Theory and Practice" pag. 274
%   App. C.
%   Input: 
%       h :  ft or m. See unit
%       unit : either 'uk' or 'si'. By default 'si'.
%   Output: 
%       a : sound speed m/s (default) or kt

if nargin == 2 % 'uk' unit required as output and given as input
    h = h * 0.3042; % ft -> m
end

R = 287.05287; % J/(kg*K)
gamma = 1.4;
a = sqrt( gamma*R*temperature(h) );

if nargin == 2 % 'uk' unit required as output and given as input
    a = a * 1.94384; % m/s -> kt
end

end

