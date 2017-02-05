% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function [ints, roads, lanes] = SpawnVehicles(spawn_rate, num_intersections, num_roads, num_lanes, time, delta_t, type)
% spawn_rate = average number of cars appearing at any given time
% num_roads = number of roads at an intersection (this should be 4)
% num_lanes = number of lanes in each road in each direction (should be 3)
% type is a string containing 'Poisson' or 'constant'

% Spawn from uniform distribution
% INCOMPLETE SECTION, MULTIPLE INTERSECTIONS NOT ENABLED
if strcmp(type, 'constant')
    if mod(time, 1 / spawn_rate) == 0
        num_vehicles = ceil(max(delta_t * spawn_rate, 1));
        road = [];
        lane = [];
        for i = 1:num_vehicles
            int = [];
            road = [road, kron(1:num_roads, ones(1, num_lanes))];
            lane = [lane, kron(ones(1, num_roads), 1:num_lanes)];
        end
    else
        int = nan;
        road = nan;
        lane = nan;
    end
    
% Spawn from Poisson distribution
elseif strcmp(type, 'poisson')
    num_vehicles = poissrnd(spawn_rate);
  
    % max number of vehicle has upper bound by number of lanes
    max_num_vehicles = num_roads*num_lanes;
  
    % check if too many vehicles spawned
    while num_vehicles > max_num_vehicles
        num_vehicles = poissrnd(lambda); % if so, resample
    end
  
    if num_vehicles > 0
        
        int = randi([1,num_intersections], 1, num_vehicles);
        
        % Randomly choose which roads, exclude road 2 for
        % multi_intersection
        if num_intersections >= 2
            road = randi([1,num_roads-1], 1 ,num_vehicles);
            road(road==2 & int==1) = 1;
        else
            road = randi([1,num_roads], 1 ,num_vehicles);
        end
        
        lane = randi([1,num_lanes], 1, num_vehicles);
        
    else
        int = nan;
        road = nan;
        lane = nan;
    end
end
end




