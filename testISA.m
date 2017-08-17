% testISA computes p, rho, T, asound in ISA from SL to 31000 m

clc 
clear

toPlot = false; % set true for plotting

hmax = 31000; % m
h = [0:1000:hmax]./0.3042; % m -> ft
for i = 1:length(h)
    T(i) = temperature(h(i),'uk');
    p(i) = pressure(h(i),'uk');
    d(i) = density(h(i),'uk');
    a(i) = asound(h(i),'uk');
end

if toPlot
    % temperature
    figure 
    plot(T,h)
    xlabel('Temperature (K)')
    ylabel('h (ft)')
    % pressure
    figure 
    plot(p,h)
    xlabel('Pressure (psf)')
    ylabel('h (ft)')
    % density
    figure 
    plot(p,h)
    xlabel('Density (slig/ft^3)')
    ylabel('h (ft)')
    % asound
    figure 
    plot(a,h)
    xlabel('Sound speed (kt)')
    ylabel('h (ft))
end

% Check values with https://www.digitaldutch.com/atmoscalc/

hr = 5000; % ft
Tr = temperature(hr,'uk') % K
pr = pressure(hr,'uk') % psf
dr = density(hr,'uk') % slug/ft^3
ar = asound(hr,'uk') % kt
Tre = 278.244; % K
pre = 1760.80; % psf
dre = 0.00204834; % sluf/ft^3
are = 650.010; % kt
if abs(Tr-Tre)<=eps
    error('Temp @ 5000 wrong')
else
    disp('Temp @ 5000 ft OK')
end
if abs(pr-pre)<=eps
    error('Press @ 5000 wrong')
else
    disp('Press @ 5000 ft OK')
end
if abs(dr-dre)<=eps
    error('Dens @ 5000 wrong')
else
    disp('Dens @ 5000 ft OK')
end
if abs(ar-are)<=eps
    error('Asound @ 5000 wrong')
else
    disp('Asound @ 5000 ft OK')
end


hr = 25700; % m
Tr = temperature(hr) % K
pr = pressure(hr) % psf
dr = density(hr) % slug/ft^3
ar = asound(hr) % kt
Tre = 222.350; % K
pre = 2254.59; % psf
dre = 0.0353239; % sluf/ft^3
are = 298.926; % kt
if abs(Tr-Tre)<=eps
    error('Temp @ 25700 wrong')
else
    disp('Temp @ 25700 ft OK')
end
if abs(pr-pre)<=eps
    error('Press @ 25700 wrong')
else
    disp('Press @ 25700 ft OK')
end
if abs(dr-dre)<=eps
    error('Dens @ 25700 wrong')
else
    disp('Dens @ 25700 ft OK')
end
if abs(ar-are)<=eps
    error('Asound @ 25700 wrong')
else
    disp('Asound @ 25700 ft OK')
end

