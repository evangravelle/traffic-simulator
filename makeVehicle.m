function[vehicle] = makeVehicle(inters, vehicle, i, lane, road, time_enter, max_speed)
% Initializes vehicle with zero values everywhere
% i is the the vehicle number
% vehicle is the structer passed in and also passed out
% LATER ON don't pass entire vehicle array to this function, unnecessary

vehicle(i).length = 4.8;
vehicle(i).width = 2;
vehicle(i).dist_in_lane = 0;
vehicle(i).color = rand(1,3);
vehicle(i).max_velocity = max_speed;
vehicle(i).max_accel = 1.8;
vehicle(i).slow_down = -1;
vehicle(i).min_accel = -4;
vehicle(i).velocity = vehicle(i).max_velocity;
% vehicle(i).velocity = vehicle(i).max_velocity/2 + randi(vehicle(i).max_velocity/2);
vehicle(i).origin = 0;
vehicle(i).destination = 0;
vehicle(i).path = [vehicle(i).origin vehicle(i).destination];
vehicle(i).time_enter = time_enter;
vehicle(i).time_leave = -1;
vehicle(i).wait = 0;
vehicle(i).lane = lane;
vehicle(i).road = road;
vehicle(i).inters = 1;

if strcmp(inters.road(road).orientation,'vertical') == 1
    vehicle(i).starting_point = [inters.road(road).lane(lane).center,...
        inters.road(road).ending_point];
    vehicle(i).orientation = pi/2;
elseif strcmp(inters.road(road).orientation,'horizontal') == 1
    vehicle(i).starting_point = [inters.road(road).ending_point, ...
        inters.road(road).lane(lane).center];
    vehicle(i).orientation = 0;
end

vehicle(i).position = vehicle(i).starting_point;

% Sets the vehicle ahead of i
best_dist = Inf;
vehicle(i).vehicle_ahead = [];
if length(vehicle) >= 2
    for j = 1:length(vehicle) - 1
        if (vehicle(i).inters == vehicle(j).inters && vehicle(j).road == vehicle(i).road && ...
          vehicle(j).lane == vehicle(i).lane && vehicle(j).dist_in_lane > vehicle(i).dist_in_lane && ...
          vehicle(j).dist_in_lane - vehicle(i).dist_in_lane < best_dist)
            vehicle(i).vehicle_ahead = j;
            best_dist = vehicle(j).dist_in_lane - vehicle(i).dist_in_lane;
        end
    end
end

end