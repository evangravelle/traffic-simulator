% Displays the road network with vehicles

figure(1)
hold on
axis equal

corners = zeros(4,2);
for i = 1:max_num_vehicles
    
    % Finds corners of polygon
    hyp = norm([vehicle(i).length vehicle(i).width],2);
    theta = atan2(vehicle(i).width,vehicle(i).length);
    corners(1,1) = vehicle(i).position(1) + ...
      hyp*cos(vehicle(i).orientation + theta);
    corners(1,2) = vehicle(i).position(2) + ...
      hyp*sin(vehicle(i).orientation + theta);
    corners(2,1) = vehicle(i).position(1) + ...
      hyp*cos(vehicle(i).orientation + pi - theta);
    corners(2,2) = vehicle(i).position(2) + ...
      hyp*sin(vehicle(i).orientation + pi - theta);
    corners(3,1) = vehicle(i).position(1) + ...
      hyp*cos(vehicle(i).orientation + pi + theta);
    corners(3,2) = vehicle(i).position(2) + ...
      hyp*sin(vehicle(i).orientation + pi + theta);
    corners(4,1) = vehicle(i).position(1) + ...
      hyp*cos(vehicle(i).orientation + 2*pi - theta);
    corners(4,2) = vehicle(i).position(2) + ...
      hyp*sin(vehicle(i).orientation + 2*pi - theta);
    
    if ~isempty(vehicle(i).length)
        fill(corners(:,1),corners(:,2),vehicle(i).color)
    end
end