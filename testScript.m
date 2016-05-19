
clear; clc; close all

% create default Intersection
[inters] = makeIntersection2(); 

% draw Intersection
[FIG] = drawIntersection(inters);

% hold on to figure, future plots on same figure
hold on;

% declare vehicle structure
vehicle = struct;

% Spawn Vehicles
lambda = 2; num_roads = 4; num_lanes = 3;
[road,lane] = poissonSpawn(lambda, num_roads, num_lanes);
if isnan(road) == 0
    for i = 1:length(road)
        [vehicle] = makeVehicle(inters,vehicle, i, lane(i), road(i), false);
        vehicle(i).figure = drawVehicle(vehicle, i);
    end
end




||||||| merged common ancestors
% make r roads and 6 lanes (in each direction) per road
num_lanes = 3;
num_roads = 4;

% first vehicle
i = 1; % vehicle number
% here false stands for 'not empty'
[vehicle] = makeVehicle(inters,vehicle, i, num_lanes, num_roads, false);
vehicle(i).figure = drawVehicle(vehicle, i);

% second vehicle
i = 2; % vehicle number
[vehicle] = makeVehicle(inters,vehicle, i, num_lanes, num_roads, false);
vehicle(i).figure = drawVehicle(vehicle, i);

% make r roads and 6 lanes (in each direction) per road
num_lanes = 3;
num_roads = 4;

% initialize simulation parameters
t = 0;
delta_t = .1;
num_iter = 100;

% lane properties


% first vehicle
i = 1; % vehicle number
time_enter = 0;
% here false stands for 'not empty'
[vehicle] = makeVehicle(inters, vehicle, i, num_lanes, num_roads, time_enter, false);
vehicle(i).figure = drawVehicle(vehicle(i), t);

% second vehicle
i = 2; % vehicle number
time_enter = 0;
[vehicle] = makeVehicle(inters, vehicle, i, num_lanes, num_roads, time_enter, false);
vehicle(i).figure = drawVehicle(vehicle(i), t);

% run simulation 
for t = delta_t*(1:num_iter)
    vehicle = runDynamics(inters, vehicle, delta_t);
    for i = 1:length(vehicle)
        delete(vehicle(i).figure);
        vehicle(i).figure = drawVehicle(vehicle(i), t);
    end
    pause(delta_t)
end

