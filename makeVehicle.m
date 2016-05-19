function[vehicle] = makeVehicle(inters, vehicle, i, num_lanes, num_roads, time_enter, empty)
    % Initializes vehicle with zero values everywhere
    % i is the the vehicle number
    % vehicle is the structer passed in and also passed out
    if empty == 1
        vehicle(i).length = 0;
        vehicle(i).width = 0;
        vehicle(i).lane = 0;
        vehicle(i).dist_in_lane = 0;
        vehicle(i).vehicle_ahead = [];
        vehicle(i).orientation = 0;
        vehicle(i).velocity = 0;
        vehicle(i).color = [0 0 0];
        vehicle(i).max_accel = 0;
        vehicle(i).min_accel = 0;
        vehicle(i).origin = 0;
        vehicle(i).destination = 0;
        vehicle(i).path = [vehicle(i).origin vehicle(i).destination];
        vehicle(i).time_enter = 0;
        vehicle(i).time_leave = 0;
    % Initializes vehicles with values
    else
        vehicle(i).length = 4.8;
        vehicle(i).width = 2;
        vehicle(i).dist_in_lane = 0;
        vehicle(i).vehicle_ahead = [];
        vehicle(i).velocity = 1;
        vehicle(i).color = rand(1,3);
        vehicle(i).max_velocity = 30;
        vehicle(i).max_accel = 1.8;
        vehicle(i).min_accel = -3;
        vehicle(i).origin = 0;
        vehicle(i).destination = 0;
        vehicle(i).path = [vehicle(i).origin vehicle(i).destination];
        vehicle(i).time_enter = time_enter;
        vehicle(i).time_leave = -1;
        vehicle(i).lane = lane;
        vehicle(i).road = road;
        if strcmp(inters.road(road).orientation,'vertical') == 1
            vehicle(i).position = [inters.road(road).lane(lane).center,...
                inters.road(road).ending_point];
            vehicle(i).orientation = pi/2;%pi*rand();
        elseif strcmp(inters.road(road).orientation,'horizontal') == 1
            vehicle(i).position = [inters.road(road).ending_point, ...
                inters.road(road).lane(lane).center];
            vehicle(i).orientation = 0;%pi*rand();
        end
    end 
end