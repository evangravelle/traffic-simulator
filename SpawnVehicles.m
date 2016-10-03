function [road, lane] = SpawnVehicles(spawn_rate, num_roads, num_lanes, time, delta_t, type)
% spawn_rate = average number of cars appearing at any given time
% num_roads = number of roads at an intersection (this should be 4)
% num_lanes = number of lanes in each road in each direction (should be 3)
% type is a string containing 'Poisson' or 'constant'

road_lanes = repmat(1:num_lanes, 1, num_roads);

% Spawn from Poisson distribution
if strcmp(type, 'constant')
    if mod(time, 1 / spawn_rate) == 0
        num_vehicles = ceil(max(delta_t * spawn_rate, 1));
        road = [];
        lane = [];
        for i = 1:num_vehicles
            road = [road, kron(1:num_roads, ones(1, num_lanes))];
            lane = [lane, kron(ones(1, num_roads), 1:num_lanes)];
        end
    else
        road = nan;
        lane = nan;
    end
    
% Spawn from Poisson distribution or from uniform
elseif strcmp(type, 'constant')
    num_vehicles = poissrnd(spawn_rate);
  
    % max number of vehicle has upper bound by number of lanes
    max_num_vehicles = num_roads*num_lanes;
  
    % check if too many vehicles spawned
    while num_vehicles > max_num_vehicles;
        num_vehicles = poissrnd(lambda); % if so change again
    end
  
    if num_vehicles > 0
        road = randi([1,num_roads], 1 ,num_vehicles);
        lane = randi([1,num_lanes], 1, num_vehicles);
        for j = 1:num_vehicles
            k = road(j);
            lane_index = randi([1,length(road_lanes(k, :))]);
            lane(j) = road_lanes(k, lane_index);
            road_lanes(k, lane_index) = [];
        end
    else
        road = nan;
        lane = nan;
    end
end
end




