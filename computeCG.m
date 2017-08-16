function [xCG, weight] = computeCG(empty_weight, empty_weight_CG_position, station_load, fuel)
%COMPUTECG Returns xCG with payload and fuel.

weight = empty_weight;
moment = empty_weight.*empty_weight_CG_position;

dim = size(station_load);
nrow = dim(1);
for i=1:nrow
    weight = weight + station_load(i,1);
    moment = moment + station_load(i,1) .* station_load(i,2:end);
end

dim = size(fuel);
nrow = dim(1);
for i=1:nrow
    weight = weight + fuel(i,end) * 6.7; % convert USG -> lb
    moment = moment + (fuel(i,end) * 6.7) .* fuel(i,1:end-1);
end

xCG= moment ./weight;

end

