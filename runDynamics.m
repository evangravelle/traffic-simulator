function vehicle = runDynamics(inters, vehicle, t, delta_t)
% Note, inters should be made more clear, is it whole struct?
% Outputs vehicle array with new positions
for i = 1:length(vehicle)
    % if a vehicle is in the system, then update position
    if (vehicle(i).time_enter ~= -1 && vehicle(i).time_leave == -1)
        
        current_road = vehicle(i).road;
        current_lane = vehicle(i).lane;
        current_inters = vehicle(i).inters;
        
        % calculate linear distance travelled
        vehicle(i).dist_in_lane = vehicle(i).dist_in_lane + vehicle(i).velocity*delta_t;
        
        % if the vehicle has fully traversed the current road
        if vehicle(i).dist_in_lane > inters(current_inters).road(current_road).length
            
            % Uses local indexing
            lane_temp = 2*inters.road(1).num_lanes*(current_road-1) + current_lane;
            if inters(current_inters).connections(lane_temp) ~= 0
                vehicle(i).dist_in_lane = vehicle(i).dist_in_lane - inters.road(current_road).length;
                lane_temp_2 = inters(current_inters).connections(lane_temp);
                vehicle(i).lane = mod(lane_temp_2-1,2*inters.road(1).num_lanes)+1;
                vehicle(i).road = floor((lane_temp_2-1)/(2*inters.road(1).num_lanes))+1;
                
                if strcmp(inters(current_inters).road(vehicle(i).road).orientation,'vertical') == 1
                    vehicle(i).starting_point = [inters(current_inters).road(vehicle(i).road).lane(vehicle(i).lane).center, ...
                      inters(current_inters).road(vehicle(i).road).starting_point];
                    vehicle(i).orientation = pi/2;
                elseif strcmp(inters(current_inters).road(vehicle(i).road).orientation,'horizontal') == 1
                    vehicle(i).starting_point = [inters(current_inters).road(vehicle(i).road).starting_point, ...
                      inters(current_inters).road(vehicle(i).road).lane(vehicle(i).lane).center];
                    vehicle(i).orientation = 0;
                end

            else
                vehicle(i).dist_in_lane = 0;
                vehicle(i).time_leave = t;
            end
        end
        
        % calculates new position
        vehicle(i).position = vehicle(i).starting_point + ...
          (Rotate2d(inters(current_inters).road(vehicle(i).road).lane(vehicle(i).lane).direction)*[1 0]')'*vehicle(i).dist_in_lane;
        
        % calculates proposed velocities, takes minimum of them
        v1 = vehicle(i).max_velocity;
        v2 = vehicle(i).velocity + vehicle(i).max_accel*delta_t;
        if isempty(vehicle(i).vehicle_ahead)
            v3 = vehicle(i).max_velocity;
        elseif vehicle(vehicle(i).vehicle_ahead).dist_in_lane - vehicle(i).dist_in_lane < vehicle(i).velocity
            v3 = abs(vehicle(i).velocity + vehicle(i).min_accel*delta_t);
        else
            v3 = vehicle(i).max_velocity;
        end
        
        % distance to intersection
        stop_dist = inters(current_inters).road(current_road).length - vehicle(i).dist_in_lane;
        
        % distance if brakes are slammed
        brake_dist = 0.5*abs(vehicle(i).velocity^2/vehicle(i).min_accel);
        
        % if the vehicle is too close and the light is not green, then slow
        if ((stop_dist - 5 < brake_dist) && ... 
          ~ismember(current_road,inters(current_inters).green))
            % a = -(2/3)*vehicle(i).velocity^2/stop_dist;
            v4 = abs(vehicle(i).velocity + vehicle(i).min_accel*delta_t);
        else
            v4 = vehicle(i).max_velocity;
        end
        
        vehicle(i).velocity = min([v1 v2 v3 v4]);
    end
end