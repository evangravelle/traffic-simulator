% Displays the road network with vehicles

figure(1)
hold on
xlim([0 200])
ylim([0 200])
axis equal
axis off
set(figure(1),'color','w');

% Displays road lines, 200m by 200m window
x0 = 0;
x1 = road_length - num_lanes*lane_width;
x2 = road_length + num_lanes*lane_width;
x3 = 2*road_length;
mid_offset = lane_width*num_lanes;
line([x0 x1 x1],[x1 x1 x0],'LineWidth',line_width,'Color',line_color)
line([x2 x2 x3],[x0 x1 x1],'LineWidth',line_width,'Color',line_color)
line([x3 x2 x2],[x2 x2 x3],'LineWidth',line_width,'Color',line_color)
line([x1 x1 x0],[x3 x2 x2],'LineWidth',line_width,'Color',line_color)
line([x0 x1],[x1 x1]+mid_offset,'LineWidth',line_width,'Color',mid_color)
line([x2 x2]-mid_offset,[x0 x1],'LineWidth',line_width,'Color',mid_color)
line([x3 x2],[x2 x2]-mid_offset,'LineWidth',line_width,'Color',mid_color)
line([x1 x1]+mid_offset,[x3 x2],'LineWidth',line_width,'Color',mid_color)

for i = 1:num_lanes-1
    line([x0 x1],[x1 x1]+i*lane_width, ...
      'LineWidth',line_width*.8,'Color',line_divider,'LineStyle','--')
    line([x0 x1],[x1 x1]+(i+num_lanes)*lane_width, ...
      'LineWidth',line_width*.8,'Color',line_divider,'LineStyle','--')
    line([x2 x2]-i*lane_width,[x0 x1], ...
      'LineWidth',line_width*.8,'Color',line_divider,'LineStyle','--')
    line([x2 x2]-(i+num_lanes)*lane_width,[x0 x1], ...
      'LineWidth',line_width*.8,'Color',line_divider,'LineStyle','--')
    line([x3 x2],[x2 x2]-i*lane_width, ...
      'LineWidth',line_width*.8,'Color',line_divider,'LineStyle','--')
    line([x3 x2],[x2 x2]-(i+num_lanes)*lane_width, ...
      'LineWidth',line_width*.8,'Color',line_divider,'LineStyle','--')
    line([x1 x1]+i*lane_width,[x3 x2], ...
      'LineWidth',line_width*.8,'Color',line_divider,'LineStyle','--')
    line([x1 x1]+(i+num_lanes)*lane_width,[x3 x2], ...
      'LineWidth',line_width*.8,'Color',line_divider,'LineStyle','--')
end
    
corners = zeros(4,2);
for i = 1:max_num_vehicles
    
    % Finds corners of polygon
    hyp = norm([vehicle(i).length/2 vehicle(i).width/2],2);
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