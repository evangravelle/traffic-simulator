% Initializes the simulation
% Note, units are metric and in radians

max_num_vehicles = 5;
num_lanes = 3;
lane_width = 3;
road_length = 100;
line_width = 0.5;
line_color = 'k';
line_divider = [.5 .5 .5];
mid_color = 'k';

% Initializes a dummy vehicle for testing and establishing the array
vehicle(max_num_vehicles+1).length = 4;
vehicle(max_num_vehicles+1).width = 2.5;
vehicle(max_num_vehicles+1).position = 200*rand(1,2);
vehicle(max_num_vehicles+1).orientation = 0;
vehicle(max_num_vehicles+1).color = rand(1,3);
for i = 1:max_num_vehicles
    vehicle(i).length = 4;
    vehicle(i).width = 2.5;
    vehicle(i).position = 200*rand(1,2);
    vehicle(i).orientation = pi*rand();
    vehicle(i).color = rand(1,3);
end