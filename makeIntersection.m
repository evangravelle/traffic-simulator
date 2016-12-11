% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function[inters] = MakeIntersection(num_intersections, lane_width, lane_length, num_lanes, all_straight)
% Declare structures
inters(num_intersections) = struct;
inters.road.lane = struct;
inters.green = struct;
inters.connections = struct;
inters.ul = struct;
inters.ur = struct;
inters.bl = struct;
inters.br = struct;

% Make the Intersection
for k = 1:num_intersections
    inters(k).center = [0,0];
    for j = 1:4 % 4 roads
        inters(k).road(j).lane_width = lane_width; %width of each lane at intersection
        inters(k).road(j).length = lane_length; %length of each road
        inters(k).road(j).num_lanes = num_lanes; %number of lanes in each direction
        inters(k).road(j).width = 2*(inters(k).road(j).lane_width)*(inters(k).road(j).num_lanes);
        inters(k).road(j).border_lanes = [2,5]; %lanes for which we will draw a border
        inters(k).ul = inters(k).center + [-num_lanes*lane_width, num_lanes*lane_width];
        inters(k).ur = inters(k).center + [num_lanes*lane_width, num_lanes*lane_width];
        inters(k).bl = inters(k).center + [-num_lanes*lane_width, -num_lanes*lane_width];
        inters(k).br = inters(k).center + [num_lanes*lane_width, -num_lanes*lane_width];
        %Define Road 1
        if j == 1
            %Road Center is a scalar
            inters(k).road(j).center = inters(k).center(1);
            %Note Orientation of Road
            inters(k).road(j).orientation = 'vertical';
            %Road Starting Point and Ending Point
            inters(k).road(j).starting_point = inters(k).center(2) + ...
                inters(k).road(j).num_lanes*inters(k).road(j).lane_width;
            inters(k).road(j).ending_point = inters(k).road(j).starting_point ...
                + inters(k).road(j).length;
            %Define incoming lanes
            for i = 1:inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = 3*pi/2;
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    - inters(k).road(j).width/2 + i*inters(k).road(j).lane_width ...
                    - inters(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = inters(k).road(j).num_lanes+1:2*inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = pi/2;
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    - inters(k).road(j).width/2 + i*inters(k).road(j).lane_width ...
                    - inters(k).road(j).lane_width/2;
            end
        %Define Road 2
        elseif j == 2
            %Road Center is a vector coordinate
            inters(k).road(j).center = inters(k).center(2);
            %Note Orientation of Road
            inters(k).road(j).orientation = 'horizontal';
            %Road Starting Point and Ending Point
            inters(k).road(j).starting_point = inters(k).center(1) + ...
                inters(k).road(j).num_lanes*inters(k).road(j).lane_width;
            inters(k).road(j).ending_point = inters(k).road(j).starting_point ...
                + inters(k).road(j).length;
            %Define incoming lanes
            for i = 1:inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = pi;
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    + inters(k).road(j).width/2 - i*inters(k).road(j).lane_width ...
                    + inters(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = inters(k).road(j).num_lanes+1:2*inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = 0;
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    + inters(k).road(j).width/2 - i*inters(k).road(j).lane_width ...
                    + inters(k).road(j).lane_width/2;
            end
        %Define Road 2
        elseif j == 3
            %Road Center is a vector coordinate
            inters(k).road(j).center = inters(k).center(1);
            %Note Orientation of Road
            inters(k).road(j).orientation = 'vertical';
            %Road Starting Point and Ending Point
            inters(k).road(j).starting_point = inters(k).center(2) - ...
                inters(k).road(j).num_lanes*inters(k).road(j).lane_width;
            inters(k).road(j).ending_point = inters(k).road(j).starting_point ...
                - inters(k).road(j).length;
            %Define incoming lanes
            for i = 1:inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = pi/2;
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    + inters(k).road(j).width/2 - i*inters(k).road(j).lane_width ...
                    + inters(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = inters(k).road(j).num_lanes+1:2*inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = 3*pi/2;
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    + inters(k).road(j).width/2 - i*inters(k).road(j).lane_width ...
                    + inters(k).road(j).lane_width/2;
            end
        %Define Road 2
        elseif j == 4
            %Road Center is a vector coordinate
            inters(k).road(j).center = inters(k).center(2);
            %Note Orientation of Road
            inters(k).road(j).orientation = 'horizontal';
            %Road Starting Point and Ending Point
            inters(k).road(j).starting_point = inters(k).center(1) - ...
                inters(k).road(j).num_lanes*inters(k).road(j).lane_width;
            inters(k).road(j).ending_point = inters(k).road(j).starting_point ...
                - inters(k).road(j).length;
            %Define incoming lanes
            for i = 1:inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = 0;
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    - inters(k).road(j).width/2 + i*inters(k).road(j).lane_width ...
                    - inters(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = inters(k).road(j).num_lanes+1:2*inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = pi;
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    - inters(k).road(j).width/2 + i*inters(k).road(j).lane_width ...
                    - inters(k).road(j).lane_width/2;
            end
        end
    end
    
    % defines lane connections. Negative connection indicates in an
    % intersection
    num = inters(k).road(1).num_lanes;
    inters(k).connections = zeros(8*num,1);
    
    if all_straight
        
        % straights
        for i = 1:num
            inters(k).connections(i) = 6*num-i+1;
            inters(k).connections(2*num+i) = 8*num-i+1;
            inters(k).connections(4*num+i) = 2*num-i+1;
            inters(k).connections(6*num+i) = 4*num-i+1;
        end
        
    else
    
        % right turns
        inters(k).connections(1) = 8*num;
        inters(k).connections(2*num+1) = 2*num;
        inters(k).connections(4*num+1) = 4*num;
        inters(k).connections(6*num+1) = 6*num;

        % left turns
        inters(k).connections(num) = 3*num+1;
        inters(k).connections(3*num) = 5*num+1;
        inters(k).connections(5*num) = 7*num+1;
        inters(k).connections(7*num) = num+1;

        % straights
        for i = 2:num-1
            inters(k).connections(i) = 6*num-i+1;
            inters(k).connections(2*num+i) = 8*num-i+1;
            inters(k).connections(4*num+i) = 2*num-i+1;
            inters(k).connections(6*num+i) = 4*num-i+1;
        end
    
    end
    
end
end
 



