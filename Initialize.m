% Initializes the simulation
% Note, units are metric and in radians
clear; clc; close all

max_num_vehicles = 5;

% Initializes a dummy vehicle for testing and establishing the array
vehicle(max_num_vehicles+1).length = 3;
vehicle(max_num_vehicles+1).width = 2;
vehicle(max_num_vehicles+1).position = 40*rand(1,2)-20;
vehicle(max_num_vehicles+1).orientation = 0;
vehicle(max_num_vehicles+1).color = rand(1,3);
for i = 1:max_num_vehicles
    vehicle(i).length = 3;
    vehicle(i).width = 2;
    vehicle(i).position = 40*rand(1,2)-20;
    vehicle(i).orientation = pi*rand();
    vehicle(i).color = rand(1,3);
end