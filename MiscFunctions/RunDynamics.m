% Written by Evan Gravelle
% 12/11/16

function vehicles = RunDynamics(ints, vehicles, straight_list, turn_radius, turn_length, wait_thresh, t, delta_t)
% Outputs vehicle array with new positions after delta_t seconds

% calculates positions of vehicle and ahead, for use in velocity calcs
V = length(vehicles);
lane_global = zeros(V,1);
ahead_lane_global = zeros(V,1);
for v = 1:V
    lane_global(v) = 2*ints(1).roads(1).num_lanes*(vehicles(v).road-1) + abs(vehicles(v).lane);
    if ~isempty(vehicles(v).ahead)
        ahead_lane_global(v) = 2*ints(1).roads(1).num_lanes*(vehicles(vehicles(v).ahead).road-1) + ...
          vehicles(vehicles(v).ahead).lane;
    end
end

for v = 1:V
    % if a vehicle is in the system, then update position
    if (vehicles(v).time_enter ~= -1 && vehicles(v).time_leave == -1)
        
        current_road = vehicles(v).road;
        current_lane = vehicles(v).lane;
        current_int = vehicles(v).int;
        num_lanes = ints(current_int).roads(vehicles(v).road).num_lanes;
        
        % calculate linear distance travelled
        vehicles(v).dist_in_lane = vehicles(v).dist_in_lane + vehicles(v).velocity*delta_t;
        
        % if the vehicle has left the current road
        if vehicles(v).dist_in_lane > ints(current_int).roads(current_road).length && ...
          vehicles(v).lane > 0
      
            % if there is a lane to connect to and same int
            new_int = ints(current_int).connections(lane_global(v),1);
            lane_global_new = ints(current_int).connections(lane_global(v),2);
            if (lane_global_new ~= 0 && vehicles(v).int == new_int)
                vehicles(v).dist_in_lane = vehicles(v).dist_in_lane - ints(current_int).roads(current_road).length;
                % negative lane indicates inside intersections
                vehicles(v).lane = -vehicles(v).lane;
                
            % if there is a lane to connect to and different int
            elseif (lane_global_new ~= 0 && vehicles(v).int ~= new_int)

                vehicles(v).dist_in_lane = vehicles(v).dist_in_lane - ints(current_int).roads(current_road).length;
                vehicles(v).int = new_int;
                vehicles(v).road = mod(vehicles(v).road + 1, 4) + 1;
                vehicles(v).lane = mod(lane_global_new - 1, num_lanes) + 1;
                % disp(vehicles(v).road)
                
                if strcmp(ints(new_int).roads(vehicles(v).road).orientation,'vertical')
                    vehicles(v).starting_point = [0 + ... % ints(new_int).center(1)
                      ints(new_int).roads(vehicles(v).road).lanes(vehicles(v).lane).center, ...
                      ints(new_int).roads(vehicles(v).road).ending_point];
                elseif strcmp(ints(new_int).roads(vehicles(v).road).orientation,'horizontal')
                    vehicles(v).starting_point = [0 + ... % ints(new_int).center(1)
                      ints(new_int).roads(vehicles(v).road).ending_point, ...
                      ints(new_int).roads(vehicles(v).road).lanes(vehicles(v).lane).center];
                end

            else
                % delete vehicle here?
                vehicles(v).dist_in_lane = 0;
                vehicles(v).time_leave = t;
            end
            
        end
        
        % if the vehicle has left the intersection
        if vehicles(v).lane < 0 && vehicles(v).dist_in_lane > turn_length(-vehicles(v).lane)
            
            % if there is a lane to connect to
            int_new = ints(current_int).connections(lane_global(v),1);
            lane_global_new = ints(current_int).connections(lane_global(v),2);
            if lane_global_new ~= 0
                
                vehicles(v).dist_in_lane = vehicles(v).dist_in_lane - turn_length(-vehicles(v).lane);
                
                vehicles(v).lane = mod(lane_global_new - 1, 2*num_lanes) + 1;
                % vehicles(v).road = mod(vehicles(v).road + 1, 4) + 1;
                vehicles(v).road = floor((lane_global_new-1)/(2*num_lanes)) + 1;
                
                if strcmp(ints(int_new).roads(vehicles(v).road).orientation,'vertical')
                    vehicles(v).starting_point = [ints(int_new).roads(vehicles(v).road).lanes(vehicles(v).lane).center, ...
                      ints(int_new).roads(vehicles(v).road).starting_point];
                    vehicles(v).orientation = pi/2;
                elseif strcmp(ints(int_new).roads(vehicles(v).road).orientation,'horizontal')
                    vehicles(v).starting_point = [ints(int_new).roads(vehicles(v).road).starting_point, ...
                      ints(int_new).roads(vehicles(v).road).lanes(vehicles(v).lane).center];
                    vehicles(v).orientation = 0;
                end

            else
                vehicles(v).dist_in_lane = 0;
                vehicles(v).time_leave = t;
            end
        end
        
        % Calculate the updated position. If left the system:
        if vehicles(v).time_leave ~= -1
            % do nothing
        % If remaining on road:
        elseif vehicles(v).lane > 0
            vehicles(v).position = vehicles(v).starting_point + ...
              (Rotate2d(ints(current_int).roads(vehicles(v).road).lanes(abs(vehicles(v).lane)).direction)*[1 0]')' * ...
              vehicles(v).dist_in_lane;
        % If in intersection going straight
        elseif ismember(-vehicles(v).lane, straight_list)
            vehicles(v).position = vehicles(v).starting_point + ...
              (Rotate2d(ints(current_int).roads(vehicles(v).road).lanes(-vehicles(v).lane).direction)*[1 0]')' * ...
              (vehicles(v).dist_in_lane + ints(current_int).roads(vehicles(v).road).length);
        else  % If in intersection turning
            r = turn_radius(-vehicles(v).lane);
            dth = .5*pi*vehicles(v).dist_in_lane/turn_length(-vehicles(v).lane);
            
            if vehicles(v).lane ~= -1 && vehicles(v).lane ~= -num_lanes
                if vehicles(v).road == 1
                    vehicles(v).position = vehicles(v).starting_point + [0, -vehicles(v).dist_in_lane];
                elseif vehicles(v).road == 2
                    vehicles(v).position = vehicles(v).starting_point + [-vehicles(v).dist_in_lane, 0];
                elseif vehicles(v).road == 3
                    vehicles(v).position = vehicles(v).starting_point + [0, vehicles(v).dist_in_lane];
                elseif vehicles(v).road == 4
                    vehicles(v).position = vehicles(v).starting_point + [vehicles(v).dist_in_lane, 0];
                end
            elseif vehicles(v).road == 1 && vehicles(v).lane == -1
                th = 0 - dth;
                vehicles(v).position = ints(current_int).ul + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = pi/2 - dth;
            elseif vehicles(v).road == 1 && vehicles(v).lane == -num_lanes
                th = pi + dth;
                vehicles(v).position = ints(current_int).ur + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = pi/2 + dth;
            elseif vehicles(v).road == 2 && vehicles(v).lane == -1
                th = 3*pi/2 - dth;
                vehicles(v).position = ints(current_int).ur + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = 0 - dth;
            elseif vehicles(v).road == 2 && vehicles(v).lane == -num_lanes
                th = pi/2 + dth;
                vehicles(v).position = ints(current_int).br + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = 0 + dth;
            elseif vehicles(v).road == 3 && vehicles(v).lane == -1
                th = pi - dth;
                vehicles(v).position = ints(current_int).br + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = pi/2 - dth;
            elseif vehicles(v).road == 3 && vehicles(v).lane == -num_lanes
                th = 0 + dth;
                vehicles(v).position = ints(current_int).bl + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = pi/2 + dth;
            elseif vehicles(v).road == 4 && vehicles(v).lane == -1
                th = pi/2 - dth;
                vehicles(v).position = ints(current_int).bl + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = 0 - dth;
            elseif vehicles(v).road == 4 && vehicles(v).lane == -num_lanes
                th = 3*pi/2 + dth;
                vehicles(v).position = ints(current_int).ul + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = 0 + dth;
            end
        end
        
        % Calculates proposed velocities, takes minimum of them
        v1 = vehicles(v).max_velocity;
        
        % After speeding up
        v2 = vehicles(v).velocity + vehicles(v).max_accel*delta_t;
        
        int_length = 2 * ints(current_int).roads(current_road).lane_width * num_lanes;
        int_dist = ints(current_int).roads(current_road).length - vehicles(v).dist_in_lane;
        brake_dist_i = 0.5*vehicles(v).velocity^2/abs(vehicles(v).min_accel); 
        
        % Considering the vehicle ahead
        % if the vehicle has left or there is no vehicle ahead
        if isempty(vehicles(v).ahead) || ...
          vehicles(vehicles(v).ahead).time_leave ~= -1
          % vehicle(vehicle(i).ahead).road ~= vehicle(i).road || ...
            v3 = vehicles(v).max_velocity;
        else
            brake_dist_ahead = 0.5*vehicles(vehicles(v).ahead).velocity^2/abs(vehicles(vehicles(v).ahead).min_accel);
            
            % if v and ahead in the same section
            if (lane_global(v) == ahead_lane_global(v) && vehicles(v).int == vehicles(vehicles(v).ahead).int)
                dist_ahead = vehicles(vehicles(v).ahead).dist_in_lane - vehicles(v).dist_in_lane;
            % if v on road and ahead in intersection
            elseif (lane_global(v) == -ahead_lane_global(v) && vehicles(v).int == vehicles(vehicles(v).ahead).int)
                dist_ahead = vehicles(vehicles(v).ahead).dist_in_lane + ...
                  ints(current_int).roads(current_road).length - vehicles(v).dist_in_lane;
            % if v in intersection and ahead on road ahead
            elseif current_lane < 0
                dist_ahead = turn_length(-current_lane) - vehicles(v).dist_in_lane + ...
                  vehicles(vehicles(v).ahead).dist_in_lane;
            % if v on road and ahead on road ahead
            elseif (vehicles(v).int == vehicles(vehicles(v).ahead).int && ...
              vehicles(v).road ~= vehicles(vehicles(v).ahead).road)
                dist_ahead = ints(current_int).roads(current_road).length - vehicles(v).dist_in_lane + ...
                  vehicles(vehicles(v).ahead).dist_in_lane;
            % if v and ahead in different intersections
            else 
                dist_ahead = vehicles(vehicles(v).ahead).dist_in_lane + ...
                  ints(current_int).roads(current_road).length - vehicles(v).dist_in_lane;
            end
                
            if dist_ahead + brake_dist_ahead - ...
              (brake_dist_i + vehicles(v).velocity*1) < 1.5*vehicles(v).length
                v3 = max(0,vehicles(v).velocity + vehicles(v).min_accel*delta_t);
            else
                v3 = vehicles(v).max_velocity;
            end
        end
        
        % after considering the interection ahead
        % if a vehicle cannot stop in time, then it doesn't slow
        
        % This accounts for extra distance caused by discrete time step
        buffer_length = 0.5 * delta_t * vehicles(v).max_velocity; 
        
        % if vehicle is approaching a non-green light
        v4 = vehicles(v).max_velocity;
        veh_phase = 2*vehicles(v).road - floor(vehicles(v).lane/num_lanes);
        if (ismember(vehicles(v).lane,1:num_lanes) && ...
          ints(vehicles(v).int).lights(veh_phase) ~= 'g')
      
            % if the vehicle can make it through the intersection
            if (int_dist - buffer_length - 2.5*vehicles(v).length < brake_dist_i)
                v4 = max(0,vehicles(v).velocity + vehicles(v).min_accel*delta_t);
            end
            
        end
        
        vehicles(v).velocity = min([v1 v2 v3 v4]);

        new_road = vehicles(v).road;
        new_lane = vehicles(v).lane;
        new_int = vehicles(v).int;

         % adds wait time
        if vehicles(v).dist_in_lane < ints(new_int).roads(new_road).length && ...
          new_lane > 0 && vehicles(v).velocity <= wait_thresh*vehicles(v).max_velocity
            vehicles(v).wait(new_int) = vehicles(v).wait(new_int) + delta_t;
        end

        % if the vehicle just left the current road
        % if vehicles(v).dist_in_lane > ints(new_int).roads(new_road).length && ...
        %   new_lane > 0
            % resets wait time
        %     vehicles(v).wait = 0;
        % end

        % if vehicle(i).wait > 0
        %     fprintf('vehicle %d has waited %.2f\n', i, vehicle(i).wait)
        % end
    end
end