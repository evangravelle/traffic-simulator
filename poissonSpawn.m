function[road,lane] = poissonSpawn(lambda, num_roads, num_lanes)
% Example: [road,lane] = poissonSpawn(2, 4, 3)
% lambda = average number of cars appearing at any given time
% num_roads = number of roads at an intersection (this should be 4)
% num_lanes = number of lanes in each road in each direction (should be 3)

% roadLanes Matrix
allLanes = [1, 2, 3];
roadLanes{1} = allLanes;
roadLanes{2} = allLanes;
roadLanes{3} = allLanes;
roadLanes{4} = allLanes;

% generate a random number from the Poisson Distribution with param lambda
% num_vehicles = poissrnd(lambda);
num_vehicles = randi(2*lambda); % This is to run on Evan's computer

% max number of vehicle has upper bound by number of lanes
max_num_vehicles = num_roads*num_lanes;

% check if produced too many vehicles
while num_vehicles > max_num_vehicles;
    num_vehicles = poissrnd(lambda); % if so change again
end

if num_vehicles > 0 % check to see if any cars are made if so ...
    road = randi([1,num_roads],1,num_vehicles); % make random vector of roads
    lane = randi([1,num_lanes],1,num_vehicles); % vector of lanes, one entry for each vehicle
    
    for j = 1:num_vehicles
        k = road(j);
        lane_index = randi([1,length(roadLanes{k})]);
        lane(j) = roadLanes{k}(lane_index);
        roadLanes{k}(lane_index) = [];
    end
else
    road = nan;
    lane = nan;
end


