% Initializes the simulation
% Note, units are metric and in radians
% Lanes are numbered CCW starting from incoming westbound lanes

delta_t = 1; % seconds
max_num_vehicles = 5;
num_intersections = 1;
num_lanes = 3;
speed_limit = 30; % kilometers per hour
lane_width = 3; % meters
road_length = 100;
line_width = 0.5;
line_color = 'k';
line_divider = [.5 .5 .5];
mid_color = 'k';
num_iter = 10;

incoming_lanes = [1:num_lanes 2*num_lanes+1:3*num_lanes ...
  4*num_lanes+1:5*num_lanes 6*num_lanes+1:7*num_lanes];
num_incoming_lanes = length(incoming_lanes);
lane_start = 100*ones(num_lanes,2); % This is temporary, for testing
lane_dir = kron([pi .5*pi 1.5*pi pi 0 1.5*pi 0.5*pi 0],ones(1,num_lanes));

% Feasible paths
paths = [1 18;2 11;3 4;7 24;8 17;9 10;13 6;14 23;15 16;19 12;20 5;21 22];

% Initializes a dummy vehicle for testing and establishing the array
vehicle(max_num_vehicles+1).length = 0;
vehicle(max_num_vehicles+1).width = 0;
vehicle(max_num_vehicles+1).lane = 0;
vehicle(max_num_vehicles+1).dist_in_lane = 0;
vehicle(max_num_vehicles+1).orientation = 0;
vehicle(max_num_vehicles+1).velocity = 0;
vehicle(max_num_vehicles+1).color = [0 0 0];
vehicle(max_num_vehicles+1).max_accel = 0;
vehicle(max_num_vehicles+1).min_accel = 0;
vehicle(max_num_vehicles+1).origin = 0;
vehicle(max_num_vehicles+1).destination = 0;
vehicle(max_num_vehicles+1).path = ...
  [vehicle(max_num_vehicles+1).origin vehicle(max_num_vehicles+1).destination];
vehicle(max_num_vehicles+1).time_enter = 0;
vehicle(max_num_vehicles+1).time_leave = 0;

for i = 1:max_num_vehicles
    vehicle(i).length = 4;
    vehicle(i).width = 2.5;
    vehicle(i).lane = incoming_lanes(randi(num_incoming_lanes));
    vehicle(i).dist_in_lane = 0;
    vehicle(i).orientation = pi*rand();
    vehicle(i).velocity = 1;
    vehicle(i).color = rand(1,3);
    vehicle(i).max_accel = 1;
    vehicle(i).min_accel = -2;
    vehicle(i).origin = 0;
    vehicle(i).destination = 0;
    vehicle(i).path = [vehicle(i).origin vehicle(i).destination];
    vehicle(i).time_enter = -1;
    vehicle(i).time_leave = -1;
end