function vehicle = RunDynamics(inter, vehicle, t, delta_t)
% Note, inter should be made more clear, is it whole struct?
% Outputs vehicle array with new positions
for i = 1:length(vehicle)
    % if a vehicle is in the system, then update position
    if (vehicle(i).time_enter ~= -1 && vehicle(i).time_leave == -1)
        
        current_road = vehicle(i).road;
        current_lane = vehicle(i).lane;
        current_inter = vehicle(i).inter;
        
        % calculate linear distance travelled
        vehicle(i).dist_in_lane = vehicle(i).dist_in_lane + vehicle(i).velocity*delta_t;
        
        % if the vehicle has fully traversed the current road
        if vehicle(i).dist_in_lane > inter(current_inter).road(current_road).length
            
            % Uses local indexing
            lane_temp = 2*inter.road(1).num_lanes*(current_road-1) + current_lane;
            if inter(current_inter).connections(lane_temp, 1) ~= 0
                vehicle(i).dist_in_lane = vehicle(i).dist_in_lane - inter.road(current_road).length;
                lane_temp_2 = inter(current_inter).connections(lane_temp);
                vehicle(i).lane = mod(lane_temp_2-1,2*inter.road(1).num_lanes)+1;
                vehicle(i).road = floor((lane_temp_2-1)/(2*inter.road(1).num_lanes))+1;
                
                if strcmp(inter(current_inter).road(vehicle(i).road).orientation,'vertical') == 1
                    vehicle(i).starting_point = [inter(current_inter).road(vehicle(i).road).lane(vehicle(i).lane).center, ...
                      inter(current_inter).road(vehicle(i).road).starting_point];
                    vehicle(i).orientation = pi/2;
                elseif strcmp(inter(current_inter).road(vehicle(i).road).orientation,'horizontal') == 1
                    vehicle(i).starting_point = [inter(current_inter).road(vehicle(i).road).starting_point, ...
                      inter(current_inter).road(vehicle(i).road).lane(vehicle(i).lane).center];
                    vehicle(i).orientation = 0;
                end

            else
                vehicle(i).dist_in_lane = 0;
                vehicle(i).time_leave = t;
            end
        end
        
        % calculates new position
        vehicle(i).position = vehicle(i).starting_point + ...
          (Rotate2d(inter(current_inter).road(vehicle(i).road).lane(vehicle(i).lane).direction)*[1 0]')'*vehicle(i).dist_in_lane;
        
        % Calculates proposed velocities, takes minimum of them
        v1 = vehicle(i).max_velocity;
        
        % after speeding up
        v2 = vehicle(i).velocity + vehicle(i).max_accel*delta_t;
        
        inter_dist = inter(current_inter).road(current_road).length - vehicle(i).dist_in_lane;
        brake_dist_i = 0.5*vehicle(i).velocity^2/abs(vehicle(i).min_accel); 
        
        % after considering the vehicle ahead
        if isempty(vehicle(i).vehicle_ahead) || ...
          vehicle(vehicle(i).vehicle_ahead).road ~= vehicle(i).road || ...
          vehicle(vehicle(i).vehicle_ahead).time_leave ~= -1
            v3 = vehicle(i).max_velocity;
        else
            brake_dist_ahead = 0.5*vehicle(vehicle(i).vehicle_ahead).velocity^2/abs(vehicle(vehicle(i).vehicle_ahead).min_accel);
            
            % this conditional accounts for 1 second reaction time and 0.5
            % car length buffer
            if (vehicle(vehicle(i).vehicle_ahead).dist_in_lane - vehicle(i).dist_in_lane + ...
              brake_dist_ahead - (brake_dist_i + vehicle(i).velocity*1) < 1.5*vehicle(i).length)
                v3 = max(0,vehicle(i).velocity + vehicle(i).min_accel*delta_t);
            else
                v3 = vehicle(i).max_velocity;
            end
        end
        
        % after considering the interection ahead, slow if facing a red
        % light
        if (ismember(vehicle(i).lane,1:inter(current_inter).road(vehicle(i).road).num_lanes) && ...
          (inter_dist - 2*vehicle(i).length < brake_dist_i) && ... 
          ~ismember(current_road,inter(current_inter).green))
            v4 = max(0,vehicle(i).velocity + vehicle(i).min_accel*delta_t);
        else
            v4 = vehicle(i).max_velocity;
        end
        
        vehicle(i).velocity = min([v1 v2 v3 v4]);
    end
end