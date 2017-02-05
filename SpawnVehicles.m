% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function [ints, roads, lanes] = SpawnVehicles(spawn_rate, num_int, num_roads, num_lanes, time, delta_t, type)
% spawn_rate = average number of cars appearing at any given time
% num_roads = number of roads at an intersection (this should be 4)
% num_lanes = number of lanes in each road in each direction (should be 3)
% type is a string containing 'Poisson' or 'constant'

% Spawn from uniform distribution
% INCOMPLETE SECTION, MULTIPLE INTERSECTIONS NOT ENABLED
if strcmp(type, 'constant')
    if mod(time, 1 / spawn_rate) == 0
        num_vehicles = ceil(max(delta_t * spawn_rate, 1));
        ints = [];
        roads = [];
        lanes = [];
        for i = 1:num_vehicles
            roads = [roads, kron(1:num_roads, ones(1, num_lanes))];
            lanes = [lanes, kron(ones(1, num_roads), 1:num_lanes)];
        end
    else
        ints = nan;
        roads = nan;
        lanes = nan;
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
        
        ints = randi([1,num_int], 1, num_vehicles);
        
        % Randomly choose which roads, exclude road 2 for
        % multi_intersection
        if num_int >= 2
            roads = randi([1,num_roads-1], 1 ,num_vehicles);
            roads(road==2 & int==1) = 1;
        else
            roads = randi([1,num_roads], 1 ,num_vehicles);
        end
        
        lanes = randi([1,num_lanes], 1, num_vehicles);
        
    else
        ints = nan;
        roads = nan;
        lanes = nan;
    end
end
end




