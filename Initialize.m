% Initializes the simulation
% Note, units are metric and in radians
% Lanes are numbered CCW starting from incoming westbound lanes

delta_t = 1; % seconds
num_vehicles = 0; 
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
vehicle = struct; %declares a structure for vehicles
vehicle = makeVehicles(vehicle,max_num_vehicles+1,incoming_lanes, ...
    num_incoming_lanes, true);

% Initilizes max_num_vehicles vehicles
while num_vehicles < max_num_vehicles %stop if max_num_vehicles is reached
    num_spawned = randi([0 num_lanes]); %spawn a number of vehicles randomly
    for i = 1:num_spawned %for every spawned vehcile, initialize
        vehicle = makeVehicles(vehicle,num_vehicles + i,incoming_lanes, ...
            num_incoming_lanes, false);
    end
    num_vehicles = num_vehicles + num_spawned;
end