function[handle] = drawVehicle(current_vehicle, t)

% Finds corners of polygon
hyp = norm([current_vehicle.length/2 current_vehicle.width/2],2);
theta = atan2(current_vehicle.width,current_vehicle.length);
corners(1,1) = current_vehicle.position(1) + ...
  hyp*cos(current_vehicle.orientation + theta);
corners(1,2) = current_vehicle.position(2) + ...
  hyp*sin(current_vehicle.orientation + theta);
corners(2,1) = current_vehicle.position(1) + ...
  hyp*cos(current_vehicle.orientation + pi - theta);
corners(2,2) = current_vehicle.position(2) + ...
  hyp*sin(current_vehicle.orientation + pi - theta);
corners(3,1) = current_vehicle.position(1) + ...
  hyp*cos(current_vehicle.orientation + pi + theta);
corners(3,2) = current_vehicle.position(2) + ...
  hyp*sin(current_vehicle.orientation + pi + theta);
corners(4,1) = current_vehicle.position(1) + ...
  hyp*cos(current_vehicle.orientation + 2*pi - theta);
corners(4,2) = current_vehicle.position(2) + ...
  hyp*sin(current_vehicle.orientation + 2*pi - theta);

handle = fill(corners(:,1),corners(:,2),current_vehicle.color);
axis equal
axis off
title(sprintf('t = %d',t))

end