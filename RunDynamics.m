% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function vehicles = RunDynamics(inter, vehicles, straight_list, turn_radius, turn_length, wait_thresh, yellow_time, t, delta_t)
% Note, inter should be made more clear, is it whole struct?
% Outputs vehicle array with new positions

% calculates positions of vehicle and ahead, for use in velocity
% calcs
V = length(vehicles);
lane_global = zeros(V,1);
ahead_lane_global = zeros(V,1);
for v = 1:V
    lane_global(v) = 2*inter(1).road(1).num_lanes*(vehicles(v).road-1) + abs(vehicles(v).lane);
    if ~isempty(vehicles(v).ahead)
        ahead_lane_global(v) = 2*inter(1).road(1).num_lanes*(vehicles(vehicles(v).ahead).road-1) + ...
          vehicles(vehicles(v).ahead).lane;
    end
end

for v = 1:V
    % if a vehicle is in the system, then update position
    if (vehicles(v).time_enter ~= -1 && vehicles(v).time_leave == -1)
        
        current_road = vehicles(v).road;
        current_lane = vehicles(v).lane;
        current_inter = vehicles(v).inter;
        
        % calculate linear distance travelled
        vehicles(v).dist_in_lane = vehicles(v).dist_in_lane + vehicles(v).velocity*delta_t;
        
        % if the vehicle has left the current road
        if vehicles(v).dist_in_lane > inter(current_inter).road(current_road).length && ...
          vehicles(v).lane > 0

            % if there is a lane to connect to
            lane_temp_new = inter(current_inter).connections(lane_global(v));
            if lane_temp_new ~= 0
                vehicles(v).dist_in_lane = vehicles(v).dist_in_lane - inter(current_inter).road(current_road).length;
                % negative lane indicates turning
                vehicles(v).lane = -vehicles(v).lane;
            else
                % delete vehicle here?
                vehicles(v).dist_in_lane = 0;
                vehicles(v).time_leave = t;
            end
            
        end
        
%         % if the vehicle has left the intersection
%         if vehicle(i).lane < 0 && vehicle(i).dist_in_lane > turn_length(-vehicle(i).lane)
%             
%             % if there is a lane to connect to
%             lane_global_new = inter(current_inter).connections(lane_global(i));
%             if lane_global_new ~= 0
%                 vehicle(i).dist_in_lane = vehicle(i).dist_in_lane - inter(current_inter).road(current_road).length;
%                 % negative lane indicates turning
%                 vehicle(i).lane = -vehicle(i).lane;
%             else
%                 % delete vehicle here?
%                 vehicle(i).dist_in_lane = 0;
%                 vehicle(i).time_leave = t;
%             end
%             
%         end
        
        % if the vehicle has left the intersection
        if vehicles(v).lane < 0 && vehicles(v).dist_in_lane > turn_length(-vehicles(v).lane)
            
            % if there is a lane to connect to
            lane_global_new = inter(current_inter).connections(lane_global(v));
            if lane_global_new ~= 0
                
                vehicles(v).dist_in_lane = vehicles(v).dist_in_lane - turn_length(-vehicles(v).lane);
                
                % THIS IS FOR STRAIGHT ONLY
                vehicles(v).lane = mod(lane_global_new - 1, 2*inter(1).road(current_road).num_lanes) + 1;
                vehicles(v).road = mod(vehicles(v).road + 1, 4) + 1;
                
                if strcmp(inter(current_inter).road(vehicles(v).road).orientation,'vertical') == 1
                    vehicles(v).starting_point = [inter(current_inter).road(vehicles(v).road).lane(vehicles(v).lane).center, ...
                      inter(current_inter).road(vehicles(v).road).starting_point];
                    vehicles(v).orientation = pi/2;
                elseif strcmp(inter(current_inter).road(vehicles(v).road).orientation,'horizontal') == 1
                    vehicles(v).starting_point = [inter(current_inter).road(vehicles(v).road).starting_point, ...
                      inter(current_inter).road(vehicles(v).road).lane(vehicles(v).lane).center];
                    vehicles(v).orientation = 0;
                end

            else
                vehicles(v).dist_in_lane = 0;
                vehicles(v).time_leave = t;
            end
        end
        
        % Calculate the updated position. If remaining on road:
        if vehicles(v).lane > 0
            vehicles(v).position = vehicles(v).starting_point + ...
              (Rotate2d(inter(current_inter).road(vehicles(v).road).lane(abs(vehicles(v).lane)).direction)*[1 0]')' * ...
              vehicles(v).dist_in_lane;
        % If in intersection going straight
        elseif ismember(-vehicles(v).lane, straight_list)
            vehicles(v).position = vehicles(v).starting_point + ...
              (Rotate2d(inter(current_inter).road(vehicles(v).road).lane(-vehicles(v).lane).direction)*[1 0]')' * ...
              (vehicles(v).dist_in_lane + inter(current_inter).road(vehicles(v).road).length);
        else  % If in intersection turning
            r = turn_radius(-vehicles(v).lane);
            dth = (pi/2)*vehicles(v).dist_in_lane/turn_length(-vehicles(v).lane);
            
            if vehicles(v).lane == -2
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
                vehicles(v).position = inter(current_inter).ul + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = pi/2 - dth;
            elseif vehicles(v).road == 1 && vehicles(v).lane == -3
                th = pi + dth;
                vehicles(v).position = inter(current_inter).ur + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = pi/2 + dth;
            elseif vehicles(v).road == 2 && vehicles(v).lane == -1
                th = 3*pi/2 - dth;
                vehicles(v).position = inter(current_inter).ur + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = 0 - dth;
            elseif vehicles(v).road == 2 && vehicles(v).lane == -3
                th = pi/2 + dth;
                vehicles(v).position = inter(current_inter).br + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = 0 + dth;
            elseif vehicles(v).road == 3 && vehicles(v).lane == -1
                th = pi - dth;
                vehicles(v).position = inter(current_inter).br + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = pi/2 - dth;
            elseif vehicles(v).road == 3 && vehicles(v).lane == -3
                th = 0 + dth;
                vehicles(v).position = inter(current_inter).bl + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = pi/2 + dth;
            elseif vehicles(v).road == 4 && vehicles(v).lane == -1
                th = pi/2 - dth;
                vehicles(v).position = inter(current_inter).bl + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = 0 - dth;
            elseif vehicles(v).road == 4 && vehicles(v).lane == -3
                th = 3*pi/2 + dth;
                vehicles(v).position = inter(current_inter).ul + [r*cos(th), r*sin(th)];
                vehicles(v).orientation = 0 + dth;
            end
        end
        
        % Calculates proposed velocities, takes minimum of them
        v1 = vehicles(v).max_velocity;
        
        % after speeding up
        v2 = vehicles(v).velocity + vehicles(v).max_accel*delta_t;
        
        inter_length = 2 * inter(current_inter).road(current_road).lane_width * ...
          inter(current_inter).road(current_road).num_lanes;
        inter_dist = inter(current_inter).road(current_road).length - vehicles(v).dist_in_lane;
        brake_dist_i = 0.5*vehicles(v).velocity^2/abs(vehicles(v).min_accel); 
        
        % Considering the vehicle ahead
        % if the vehicle has left or there is no vehicle ahead
        if isempty(vehicles(v).ahead) || ...
          vehicles(vehicles(v).ahead).time_leave ~= -1
          % vehicle(vehicle(i).ahead).road ~= vehicle(i).road || ...
            v3 = vehicles(v).max_velocity;
        else
            brake_dist_ahead = 0.5*vehicles(vehicles(v).ahead).velocity^2/abs(vehicles(vehicles(v).ahead).min_accel);
            
            % if in the same section
            if lane_global(v) == ahead_lane_global(v)
                dist_ahead = vehicles(vehicles(v).ahead).dist_in_lane - vehicles(v).dist_in_lane;
            % if i on road and ahead in intersection
            elseif lane_global(v) == -ahead_lane_global(v)
                dist_ahead = vehicles(vehicles(v).ahead).dist_in_lane + ...
                  inter(current_inter).road(current_road).length - vehicles(v).dist_in_lane;
            % if i in intersection and ahead on road ahead
            elseif current_lane < 0
                dist_ahead = turn_length(-current_lane) - vehicles(v).dist_in_lane + ...
                  vehicles(vehicles(v).ahead).dist_in_lane;
            % if i on road and ahead on road ahead
            else
                dist_ahead = inter(current_inter).road(current_road).length - vehicles(v).dist_in_lane + ...
                  turn_length(current_lane) + vehicles(vehicles(v).ahead).dist_in_lane;
            end
                
            if dist_ahead + ...
                brake_dist_ahead - (brake_dist_i + vehicles(v).velocity*1) < 1.5*vehicles(v).length
                  v3 = max(0,vehicles(v).velocity + vehicles(v).min_accel*delta_t);
            else
                v3 = vehicles(v).max_velocity;
            end
        end
        
        % after considering the interection ahead
        % if a vehicle cannot stop in time, then it doesn't slow
        % MUST BE REWRITTEN WHEN THERE ARE MULTIPLE INTERSECTIONS
        
        % This accounts for extra distance caused by discrete time step
        buffer_length = 0.5 * delta_t * vehicles(v).max_velocity; 
        
        % if vehicle is approaching a non-green light
        v4 = vehicles(v).max_velocity;
        if (ismember(vehicles(v).lane,1:inter(current_inter).road(vehicles(v).road).num_lanes) && ...
          ~ismember(current_road,inter(current_inter).green))
      
            % if the vehicle can make it through the intersection
            % if vehicle(i).velocity * yellow_time > inter_dist + inter_length && false
            %     v4 = vehicle(i).max_velocity;
            if (inter_dist - 1 * buffer_length - 2.5*vehicles(v).length < brake_dist_i)
                v4 = max(0,vehicles(v).velocity + vehicles(v).min_accel*delta_t);
            end
            
        end
        
        vehicles(v).velocity = min([v1 v2 v3 v4]);

        new_road = vehicles(v).road;
        new_lane = vehicles(v).lane;
        new_inter = vehicles(v).inter;

         % adds wait time
        if vehicles(v).dist_in_lane < inter(new_inter).road(new_road).length && ...
          new_lane > 0 && vehicles(v).velocity <= wait_thresh*vehicles(v).max_velocity
            vehicles(v).wait = vehicles(v).wait + delta_t;
        end

        % if the vehicle just left the current road
        if vehicles(v).dist_in_lane > inter(new_inter).road(new_road).length && ...
          new_lane > 0
            % resets wait time
            vehicles(v).wait = 0;
        end

        % if vehicle(i).wait > 0
        %     fprintf('vehicle %d has waited %.2f\n', i, vehicle(i).wait)
        % end
    end
end