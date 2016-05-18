% Outputs vehicle position and orientation over all time steps

for t = 1:num_iter
    for i = 1:max_num_vehicles
        
        % if a vehicle is in the system, then update position
        if (vehicle(i).time_enter ~= -1 && vehicle(i).time_leave == -1)
            vehicle(i).dist_in_lane = vehicle(i).position + vehicle(i).velocity*delta_t;
            vehicle(i).position = lane_start(vehicle(i).lane,:) + ...
              Rotate2d(lane_dir(vehicle(i).lane))*[1 0]'*vehicle(i).dist_in_lane;
        end
    end
end