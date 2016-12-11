% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function vehicle = RunDynamics(inter, vehicle, straight_list, turn_radius, turn_length, wait_thresh, yellow_time, t, delta_t)
% Note, inter should be made more clear, is it whole struct?
% Outputs vehicle array with new positions

% calculates positions of vehicle and ahead, for use in velocity
% calcs
V = length(vehicle);
lane_global = zeros(V,1);
ahead_lane_global = zeros(V,1);
for i = 1:V
    lane_global(i) = 2*inter(1).road(1).num_lanes*(vehicle(i).road-1) + abs(vehicle(i).lane);
    if ~isempty(vehicle(i).ahead)
        ahead_lane_global(i) = 2*inter(1).road(1).num_lanes*(vehicle(vehicle(i).ahead).road-1) + ...
          vehicle(vehicle(i).ahead).lane;
    end
end

for i = 1:V
    % if a vehicle is in the system, then update position
    if (vehicle(i).time_enter ~= -1 && vehicle(i).time_leave == -1)
        
        current_road = vehicle(i).road;
        current_lane = vehicle(i).lane;
        current_inter = vehicle(i).inter;
        
        % calculate linear distance travelled
        vehicle(i).dist_in_lane = vehicle(i).dist_in_lane + vehicle(i).velocity*delta_t;
        
        % if the vehicle has left the current road
        if vehicle(i).dist_in_lane > inter(current_inter).road(current_road).length && ...
          vehicle(i).lane > 0

            % if there is a lane to connect to
            lane_temp_new = inter(current_inter).connections(lane_global(i));
            if lane_temp_new ~= 0
                vehicle(i).dist_in_lane = vehicle(i).dist_in_lane - inter(current_inter).road(current_road).length;
                % negative lane indicates turning
                vehicle(i).lane = -vehicle(i).lane;
            else
                % delete vehicle here?
                vehicle(i).dist_in_lane = 0;
                vehicle(i).time_leave = t;
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
        if vehicle(i).lane < 0 && vehicle(i).dist_in_lane > turn_length(-vehicle(i).lane)
            
            % if there is a lane to connect to
            lane_global_new = inter(current_inter).connections(lane_global(i));
            if lane_global_new ~= 0
                
                vehicle(i).dist_in_lane = vehicle(i).dist_in_lane - turn_length(-vehicle(i).lane);
                
                % THIS IS FOR STRAIGHT ONLY
                vehicle(i).lane = mod(lane_global_new - 1, 2*inter(1).road(current_road).num_lanes) + 1;
                vehicle(i).road = mod(vehicle(i).road + 1, 4) + 1;
                
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
        
        % Calculate the updated position. If remaining on road:
        if vehicle(i).lane > 0
            vehicle(i).position = vehicle(i).starting_point + ...
              (Rotate2d(inter(current_inter).road(vehicle(i).road).lane(abs(vehicle(i).lane)).direction)*[1 0]')' * ...
              vehicle(i).dist_in_lane;
        % If in intersection going straight
        elseif ismember(-vehicle(i).lane, straight_list)
            vehicle(i).position = vehicle(i).starting_point + ...
              (Rotate2d(inter(current_inter).road(vehicle(i).road).lane(-vehicle(i).lane).direction)*[1 0]')' * ...
              (vehicle(i).dist_in_lane + inter(current_inter).road(vehicle(i).road).length);
        else  % If in intersection turning
            r = turn_radius(-vehicle(i).lane);
            dth = (pi/2)*vehicle(i).dist_in_lane/turn_length(-vehicle(i).lane);
            
            if vehicle(i).lane == -2
                if vehicle(i).road == 1
                    vehicle(i).position = vehicle(i).starting_point + [0, -vehicle(i).dist_in_lane];
                elseif vehicle(i).road == 2
                    vehicle(i).position = vehicle(i).starting_point + [-vehicle(i).dist_in_lane, 0];
                elseif vehicle(i).road == 3
                    vehicle(i).position = vehicle(i).starting_point + [0, vehicle(i).dist_in_lane];
                elseif vehicle(i).road == 4
                    vehicle(i).position = vehicle(i).starting_point + [vehicle(i).dist_in_lane, 0];
                end
            elseif vehicle(i).road == 1 && vehicle(i).lane == -1
                th = 0 - dth;
                vehicle(i).position = inter(current_inter).ul + [r*cos(th), r*sin(th)];
                vehicle(i).orientation = pi/2 - dth;
            elseif vehicle(i).road == 1 && vehicle(i).lane == -3
                th = pi + dth;
                vehicle(i).position = inter(current_inter).ur + [r*cos(th), r*sin(th)];
                vehicle(i).orientation = pi/2 + dth;
            elseif vehicle(i).road == 2 && vehicle(i).lane == -1
                th = 3*pi/2 - dth;
                vehicle(i).position = inter(current_inter).ur + [r*cos(th), r*sin(th)];
                vehicle(i).orientation = 0 - dth;
            elseif vehicle(i).road == 2 && vehicle(i).lane == -3
                th = pi/2 + dth;
                vehicle(i).position = inter(current_inter).br + [r*cos(th), r*sin(th)];
                vehicle(i).orientation = 0 + dth;
            elseif vehicle(i).road == 3 && vehicle(i).lane == -1
                th = pi - dth;
                vehicle(i).position = inter(current_inter).br + [r*cos(th), r*sin(th)];
                vehicle(i).orientation = pi/2 - dth;
            elseif vehicle(i).road == 3 && vehicle(i).lane == -3
                th = 0 + dth;
                vehicle(i).position = inter(current_inter).bl + [r*cos(th), r*sin(th)];
                vehicle(i).orientation = pi/2 + dth;
            elseif vehicle(i).road == 4 && vehicle(i).lane == -1
                th = pi/2 - dth;
                vehicle(i).position = inter(current_inter).bl + [r*cos(th), r*sin(th)];
                vehicle(i).orientation = 0 - dth;
            elseif vehicle(i).road == 4 && vehicle(i).lane == -3
                th = 3*pi/2 + dth;
                vehicle(i).position = inter(current_inter).ul + [r*cos(th), r*sin(th)];
                vehicle(i).orientation = 0 + dth;
            end
        end
        
        % Calculates proposed velocities, takes minimum of them
        v1 = vehicle(i).max_velocity;
        
        % after speeding up
        v2 = vehicle(i).velocity + vehicle(i).max_accel*delta_t;
        
        inter_length = 2 * inter(current_inter).road(current_road).lane_width * ...
          inter(current_inter).road(current_road).num_lanes;
        inter_dist = inter(current_inter).road(current_road).length - vehicle(i).dist_in_lane;
        brake_dist_i = 0.5*vehicle(i).velocity^2/abs(vehicle(i).min_accel); 
        
        % Considering the vehicle ahead
        % if the vehicle has left or there is no vehicle ahead
        if isempty(vehicle(i).ahead) || ...
          vehicle(vehicle(i).ahead).time_leave ~= -1
          % vehicle(vehicle(i).ahead).road ~= vehicle(i).road || ...
            v3 = vehicle(i).max_velocity;
        else
            brake_dist_ahead = 0.5*vehicle(vehicle(i).ahead).velocity^2/abs(vehicle(vehicle(i).ahead).min_accel);
            
            % if in the same section
            if lane_global(i) == ahead_lane_global(i)
                dist_ahead = vehicle(vehicle(i).ahead).dist_in_lane - vehicle(i).dist_in_lane;
            % if i on road and ahead in intersection
            elseif lane_global(i) == -ahead_lane_global(i)
                dist_ahead = vehicle(vehicle(i).ahead).dist_in_lane + ...
                  inter(current_inter).road(current_road).length - vehicle(i).dist_in_lane;
            % if i in intersection and ahead on road ahead
            elseif current_lane < 0
                dist_ahead = turn_length(-current_lane) - vehicle(i).dist_in_lane + ...
                  vehicle(vehicle(i).ahead).dist_in_lane;
            % if i on road and ahead on road ahead
            else
                dist_ahead = inter(current_inter).road(current_road).length - vehicle(i).dist_in_lane + ...
                  turn_length(current_lane) + vehicle(vehicle(i).ahead).dist_in_lane;
            end
                
            if dist_ahead + ...
                brake_dist_ahead - (brake_dist_i + vehicle(i).velocity*1) < 1.5*vehicle(i).length
                  v3 = max(0,vehicle(i).velocity + vehicle(i).min_accel*delta_t);
            else
                v3 = vehicle(i).max_velocity;
            end
        end
        
        % after considering the interection ahead
        % if a vehicle cannot stop in time, then it doesn't slow
        % MUST BE REWRITTEN WHEN THERE ARE MULTIPLE INTERSECTIONS
        
        % This accounts for extra distance caused by discrete time step
        buffer_length = 0.5 * delta_t * vehicle(i).max_velocity; 
        
        % if vehicle is approaching a non-green light
        v4 = vehicle(i).max_velocity;
        if (ismember(vehicle(i).lane,1:inter(current_inter).road(vehicle(i).road).num_lanes) && ...
          ~ismember(current_road,inter(current_inter).green))
      
            % if the vehicle can make it through the intersection
            % if vehicle(i).velocity * yellow_time > inter_dist + inter_length && false
            %     v4 = vehicle(i).max_velocity;
            if (inter_dist - buffer_length - 2*vehicle(i).length < brake_dist_i)
                v4 = max(0,vehicle(i).velocity + vehicle(i).min_accel*delta_t);
            end
            
        end
        
        vehicle(i).velocity = min([v1 v2 v3 v4]);

        new_road = vehicle(i).road;
        new_lane = vehicle(i).lane;
        new_inter = vehicle(i).inter;

         % adds wait time
        if vehicle(i).dist_in_lane < inter(new_inter).road(new_road).length && ...
          new_lane > 0 && vehicle(i).velocity <= wait_thresh*vehicle(i).max_velocity
            vehicle(i).wait = vehicle(i).wait + delta_t;
        end

        % if the vehicle just left the current road
        if vehicle(i).dist_in_lane > inter(new_inter).road(new_road).length && ...
          new_lane > 0
            % resets wait time
            vehicle(i).wait = 0;
        end

        % if vehicle(i).wait > 0
        %     fprintf('vehicle %d has waited %.2f\n', i, vehicle(i).wait)
        % end
    end
end