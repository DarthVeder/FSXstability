function [xCG, weight] = computeCG(empty_weight, empty_weight_CG_position, station_load, fuel)
%COMPUTECG Returns xCG with payload and fuel.
%   Input:
%       empty_weight : [lbs]
%       empty_weight_CG_position : 3 dimension vector [ft]
%       station_load : nrow by ncol matrix [weight_i, x_i, y_i, z_i] [lb, ft, ft, ft, ft]
%       fuel : nrow by ncol matrix [fuel_i, x_i, y_i, z_i] [USG, ft, ft, ft]. Conversion USG->lb is done inside.
%   Output:
%       xCG: center of gravity position [xCG, yCG, zCG] [ft, ft, ft]
%       weight : total weight [lb]
%
weight = empty_weight;
moment = empty_weight.*empty_weight_CG_position;

dim = size(station_load);
nrow = dim(1); % number of station loads
for i=1:nrow
    weight = weight + station_load(i,1);
    moment = moment + station_load(i,1) .* station_load(i,2:end);
end

dim = size(fuel); % number of tanks
nrow = dim(1);
for i=1:nrow
    weight = weight + fuel(i,end) * 6.7; % convert USG -> lb
    moment = moment + (fuel(i,end) * 6.7) .* fuel(i,1:end-1);
end

xCG= moment ./ weight;

end

