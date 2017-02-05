% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function ints = MakeIntersections(num_intersections, lane_width, lane_length, num_lanes, all_straight)
% Declare structures
ints(num_intersections) = struct;
ints.road.lane = struct;
ints.green = struct;
ints.connections = struct;
ints.ul = struct;
ints.ur = struct;
ints.bl = struct;
ints.br = struct;

% Make the Intersection
for k = 1:num_intersections
    ints(k).center = [(k-1)*2*lane_length, 0];
    for j = 1:4 % 4 roads
        ints(k).road(j).lane_width = lane_width; %width of each lane at intersection
        ints(k).road(j).length = lane_length; %length of each road
        ints(k).road(j).num_lanes = num_lanes; %number of lanes in each direction
        ints(k).road(j).width = 2*(ints(k).road(j).lane_width)*(ints(k).road(j).num_lanes);
        ints(k).road(j).border_lanes = [2,5]; %lanes for which we will draw a border
        ints(k).ul = ints(k).center + [-num_lanes*lane_width, num_lanes*lane_width];
        ints(k).ur = ints(k).center + [num_lanes*lane_width, num_lanes*lane_width];
        ints(k).bl = ints(k).center + [-num_lanes*lane_width, -num_lanes*lane_width];
        ints(k).br = ints(k).center + [num_lanes*lane_width, -num_lanes*lane_width];
        %Define Road 1
        if j == 1
            %Road Center is a scalar
            ints(k).road(j).center = ints(k).center(1);
            %Note Orientation of Road
            ints(k).road(j).orientation = 'vertical';
            %Road Starting Point and Ending Point
            ints(k).road(j).starting_point = ints(k).center(2) + ...
                ints(k).road(j).num_lanes*ints(k).road(j).lane_width;
            ints(k).road(j).ending_point = ints(k).road(j).starting_point ...
                + ints(k).road(j).length;
            %Define incoming lanes
            for i = 1:ints(k).road(j).num_lanes
                ints(k).road(j).lane(i).direction = 3*pi/2;
                ints(k).road(j).lane(i).center = ints(k).road(j).center ...
                    - ints(k).road(j).width/2 + i*ints(k).road(j).lane_width ...
                    - ints(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = ints(k).road(j).num_lanes+1:2*ints(k).road(j).num_lanes
                ints(k).road(j).lane(i).direction = pi/2;
                ints(k).road(j).lane(i).center = ints(k).road(j).center ...
                    - ints(k).road(j).width/2 + i*ints(k).road(j).lane_width ...
                    - ints(k).road(j).lane_width/2;
            end
        %Define Road 2
        elseif j == 2
            %Road Center is a vector coordinate
            ints(k).road(j).center = ints(k).center(2);
            %Note Orientation of Road
            ints(k).road(j).orientation = 'horizontal';
            %Road Starting Point and Ending Point
            ints(k).road(j).starting_point = ints(k).center(1) + ...
                ints(k).road(j).num_lanes*ints(k).road(j).lane_width;
            ints(k).road(j).ending_point = ints(k).road(j).starting_point ...
                + ints(k).road(j).length;
            %Define incoming lanes
            for i = 1:ints(k).road(j).num_lanes
                ints(k).road(j).lane(i).direction = pi;
                ints(k).road(j).lane(i).center = ints(k).road(j).center ...
                    + ints(k).road(j).width/2 - i*ints(k).road(j).lane_width ...
                    + ints(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = ints(k).road(j).num_lanes+1:2*ints(k).road(j).num_lanes
                ints(k).road(j).lane(i).direction = 0;
                ints(k).road(j).lane(i).center = ints(k).road(j).center ...
                    + ints(k).road(j).width/2 - i*ints(k).road(j).lane_width ...
                    + ints(k).road(j).lane_width/2;
            end
        %Define Road 2
        elseif j == 3
            %Road Center is a vector coordinate
            ints(k).road(j).center = ints(k).center(1);
            %Note Orientation of Road
            ints(k).road(j).orientation = 'vertical';
            %Road Starting Point and Ending Point
            ints(k).road(j).starting_point = ints(k).center(2) - ...
                ints(k).road(j).num_lanes*ints(k).road(j).lane_width;
            ints(k).road(j).ending_point = ints(k).road(j).starting_point ...
                - ints(k).road(j).length;
            %Define incoming lanes
            for i = 1:ints(k).road(j).num_lanes
                ints(k).road(j).lane(i).direction = pi/2;
                ints(k).road(j).lane(i).center = ints(k).road(j).center ...
                    + ints(k).road(j).width/2 - i*ints(k).road(j).lane_width ...
                    + ints(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = ints(k).road(j).num_lanes+1:2*ints(k).road(j).num_lanes
                ints(k).road(j).lane(i).direction = 3*pi/2;
                ints(k).road(j).lane(i).center = ints(k).road(j).center ...
                    + ints(k).road(j).width/2 - i*ints(k).road(j).lane_width ...
                    + ints(k).road(j).lane_width/2;
            end
        %Define Road 2
        elseif j == 4
            %Road Center is a vector coordinate
            ints(k).road(j).center = ints(k).center(2);
            %Note Orientation of Road
            ints(k).road(j).orientation = 'horizontal';
            %Road Starting Point and Ending Point
            ints(k).road(j).starting_point = ints(k).center(1) - ...
                ints(k).road(j).num_lanes*ints(k).road(j).lane_width;
            ints(k).road(j).ending_point = ints(k).road(j).starting_point ...
                - ints(k).road(j).length;
            %Define incoming lanes
            for i = 1:ints(k).road(j).num_lanes
                ints(k).road(j).lane(i).direction = 0;
                ints(k).road(j).lane(i).center = ints(k).road(j).center ...
                    - ints(k).road(j).width/2 + i*ints(k).road(j).lane_width ...
                    - ints(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = ints(k).road(j).num_lanes+1:2*ints(k).road(j).num_lanes
                ints(k).road(j).lane(i).direction = pi;
                ints(k).road(j).lane(i).center = ints(k).road(j).center ...
                    - ints(k).road(j).width/2 + i*ints(k).road(j).lane_width ...
                    - ints(k).road(j).lane_width/2;
            end
        end
    end
    
    % defines lane connections. Negative connection indicates in an
    % intersection
    num = ints(k).road(1).num_lanes;
    ints(k).connections = zeros(8*num,2);
    
    if all_straight
        
        % straights
        for i = 1:num
            ints(k).connections(i) = [1, 6*num-i+1];
            ints(k).connections(2*num+i) = [1, 8*num-i+1];
            ints(k).connections(4*num+i) = [1, 2*num-i+1];
            ints(k).connections(6*num+i) = [1, 4*num-i+1];
        end
        
    else
    
        % right turns
        ints(k).connections(1) = [1, 8*num];
        ints(k).connections(2*num+1) = [1, 2*num];
        ints(k).connections(4*num+1) = 4*num];
        ints(k).connections(6*num+1) = 6*num];

        % left turns
        ints(k).connections(num) = [1, 3*num+1];
        ints(k).connections(3*num) = [1, 5*num+1];
        ints(k).connections(5*num) = [1, 7*num+1];
        ints(k).connections(7*num) = [1, num+1];

        % straights
        for i = 2:num-1
            ints(k).connections(i) = [1, 6*num-i+1];
            ints(k).connections(2*num+i) = [1, 8*num-i+1];
            ints(k).connections(4*num+i) = [1, 2*num-i+1];
            ints(k).connections(6*num+i) = [1, 4*num-i+1];
        end
    
    end
 
end

% defines lane connections across intersections
for i = 1:num
    ints(1).connections(3*num+i) = [2, 7*num+1-i];
    ints(2).connections(7*num+i) = [1, 3*num+1-i];
end


end