clc 
clear

h = [0:1000:31000/0.3042]; % ft
for i = 1:length(h)
    T(i) = temperature(h(i),'uk');
    p(i) = pressure(h(i),'uk');
    d(i) = density(h(i),'uk');
    a(i) = asound(h(i),'uk');
end

toPlot = false;
if toPlot
    plot(d,h)
end

% comparison with https://www.digitaldutch.com/atmoscalc/

hr = 28500
Tr = temperature(hr,'uk')
pr = pressure(hr,'uk')
dr = density(hr,'uk')
ar = asound(hr,'uk')