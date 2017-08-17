function T = temperature(h, unit)
%TEMPERATURE ISA atmosphere temperarure up to 32 km
%   Model from Eshelby "Aircraft Performance: Theory and Practice" pag. 274
%   App. C.
%   Input: 
%       h : (ft or m). See unit.
%       unit : either 'uk' or 'si'. By default 'si'.
%   Output: 
%       T : K
%
%   Example:
%       temperature(2000) -> temperature in K at 2000 m
%
%       temperature(2000, 'uk') -> temperature in K at 2000 ft

if nargin == 2 % input in ft, must convert to m
    h = h * 0.3042; % m
end

L0 = -0.0065; % K/m
L11 = 0; % K/m
L20 = 0.001; % K/m

T = 0;
if h <= 11000
    T = 288.15 + L0*h;
elseif h <= 20000
    T = 216.55 + L11*(h - 11000);    
elseif h <= 32000
    T = 216.55 + L20*(h - 20000);
end

end

