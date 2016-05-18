clear; clc; close all

% create default Intersection
[inters] = makeIntersection2(); 

% draw Intersection
[FIG] = drawIntersection(inters);

% hold on to figure, future plots on same figure
hold on;

% declare vehicle structure
vehicle = struct;

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