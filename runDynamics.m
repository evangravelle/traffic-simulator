function vehicle = runDynamics(inters, vehicle, delta_t)
% Outputs vehicle array with new positions
for i = 1:length(vehicle)
    % if a vehicle is in the system, then update position
    if (vehicle(i).time_enter ~= -1 && vehicle(i).time_leave == -1)
        % calculate linear distance travelled
        vehicle(i).dist_in_lane = vehicle(i).dist_in_lane + vehicle(i).velocity*delta_t;
        
        % calculate which direction to move in
        disp(Rotate2d(vehicle(i).orientation))
        disp(vehicle(i).position)
        disp(vehicle(i).dist_in_lane)
        vehicle(i).position = vehicle(i).position + (Rotate2d(vehicle(i).orientation)*[1 0]')'*vehicle(i).dist_in_lane;
        if isempty(vehicle(i).vehicle_ahead)
            vehicle(i).velocity = min(vehicle(i).velocity + vehicle(i).max_accel*delta_t,vehicle(i).max_velocity);
        end
    end
end