% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function vehicles = MakeVehicle(ints, vehicles, i, int, road, lane, time_enter, max_speed)
% i is the the vehicle number
num_int = length(ints);

vehicles(i).length = 4.8;
vehicles(i).width = 2;
vehicles(i).dist_in_lane = 0;
vehicles(i).color = rand(1,3);
vehicles(i).max_velocity = max_speed;
vehicles(i).max_accel = 1.8;
vehicles(i).slow_down = -1;
vehicles(i).min_accel = -4;
vehicles(i).velocity = vehicles(i).max_velocity;
% vehicle(i).velocity = vehicle(i).max_velocity/2 + randi(vehicle(i).max_velocity/2);
% vehicles(i).origin = 0;
% vehicles(i).destination = 0;
% vehicles(i).path = [vehicles(i).origin vehicles(i).destination];
vehicles(i).time_enter = time_enter;
vehicles(i).time_leave = -1;
vehicles(i).wait = zeros(num_int,1);
vehicles(i).lane = lane;
vehicles(i).road = road;
vehicles(i).int = int;

if strcmp(ints(int).roads(road).orientation,'vertical')
    vehicles(i).starting_point = [ints(int).roads(road).lanes(lane).center,...
        ints(int).roads(road).ending_point];
    vehicles(i).orientation = pi/2;
elseif strcmp(ints(int).roads(road).orientation,'horizontal')
    vehicles(i).starting_point = [ints(int).roads(road).ending_point, ...
        ints(int).roads(road).lanes(lane).center];
    vehicles(i).orientation = 0;
end

vehicles(i).position = vehicles(i).starting_point;

% Sets the vehicle ahead of i
best_dist = Inf;
vehicles(i).ahead = [];
if length(vehicles) >= 2
    for j = 1:length(vehicles) - 1
        if (vehicles(i).int == vehicles(j).int && vehicles(j).road == vehicles(i).road && ...
          vehicles(j).lane == vehicles(i).lane && vehicles(j).dist_in_lane > vehicles(i).dist_in_lane && ...
          vehicles(j).dist_in_lane - vehicles(i).dist_in_lane < best_dist)
            vehicles(i).ahead = j;
            best_dist = vehicles(j).dist_in_lane - vehicles(i).dist_in_lane;
        end
    end
end

end