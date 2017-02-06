% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function ints = MakeIntersections(num_int, lane_width, lane_length, num_lanes, all_straight)
% Declare structures
ints(num_int) = struct;
for k = 1:num_int
    ints(k).roads.lanes = struct;
    ints(k).lights = struct;
    ints(k).connections = struct;
    ints(k).ul = struct;
    ints(k).ur = struct;
    ints(k).bl = struct;
    ints(k).br = struct;
end

% Make the Intersection
for k = 1:num_int
    ints(k).center = [(k-1)*2*lane_length, 0];
    ints(k).lights = 'grgr';
    for j = 1:4 % 4 roads
        ints(k).roads(j).lane_width = lane_width; %width of each lane at intersection
        ints(k).roads(j).length = lane_length; %length of each road
        ints(k).roads(j).num_lanes = num_lanes; %number of lanes in each direction
        ints(k).roads(j).width = 2*(ints(k).roads(j).lane_width)*(ints(k).roads(j).num_lanes);
        ints(k).roads(j).border_lanes = [2,5]; %lanes for which we will draw a border
        ints(k).ul = ints(k).center + [-num_lanes*lane_width, num_lanes*lane_width];
        ints(k).ur = ints(k).center + [num_lanes*lane_width, num_lanes*lane_width];
        ints(k).bl = ints(k).center + [-num_lanes*lane_width, -num_lanes*lane_width];
        ints(k).br = ints(k).center + [num_lanes*lane_width, -num_lanes*lane_width];
        %Define Road 1
        if j == 1
            %Road Center is a scalar
            ints(k).roads(j).center = ints(k).center(1);
            %Note Orientation of Road
            ints(k).roads(j).orientation = 'vertical';
            %Road Starting Point and Ending Point
            ints(k).roads(j).starting_point = ints(k).center(2) + ...
                ints(k).roads(j).num_lanes*ints(k).roads(j).lane_width;
            ints(k).roads(j).ending_point = ints(k).roads(j).starting_point ...
                + ints(k).roads(j).length;
            %Define incoming lanes
            for i = 1:ints(k).roads(j).num_lanes
                ints(k).roads(j).lanes(i).direction = 3*pi/2;
                ints(k).roads(j).lanes(i).center = ints(k).roads(j).center ...
                    - ints(k).roads(j).width/2 + i*ints(k).roads(j).lane_width ...
                    - ints(k).roads(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = ints(k).roads(j).num_lanes+1:2*ints(k).roads(j).num_lanes
                ints(k).roads(j).lanes(i).direction = pi/2;
                ints(k).roads(j).lanes(i).center = ints(k).roads(j).center ...
                    - ints(k).roads(j).width/2 + i*ints(k).roads(j).lane_width ...
                    - ints(k).roads(j).lane_width/2;
            end
        %Define Road 2
        elseif j == 2
            %Road Center is a vector coordinate
            ints(k).roads(j).center = ints(k).center(2);
            %Note Orientation of Road
            ints(k).roads(j).orientation = 'horizontal';
            %Road Starting Point and Ending Point
            ints(k).roads(j).starting_point = ints(k).center(1) + ...
                ints(k).roads(j).num_lanes*ints(k).roads(j).lane_width;
            ints(k).roads(j).ending_point = ints(k).roads(j).starting_point ...
                + ints(k).roads(j).length;
            %Define incoming lanes
            for i = 1:ints(k).roads(j).num_lanes
                ints(k).roads(j).lanes(i).direction = pi;
                ints(k).roads(j).lanes(i).center = ints(k).roads(j).center ...
                    + ints(k).roads(j).width/2 - i*ints(k).roads(j).lane_width ...
                    + ints(k).roads(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = ints(k).roads(j).num_lanes+1:2*ints(k).roads(j).num_lanes
                ints(k).roads(j).lanes(i).direction = 0;
                ints(k).roads(j).lanes(i).center = ints(k).roads(j).center ...
                    + ints(k).roads(j).width/2 - i*ints(k).roads(j).lane_width ...
                    + ints(k).roads(j).lane_width/2;
            end
        %Define Road 2
        elseif j == 3
            %Road Center is a vector coordinate
            ints(k).roads(j).center = ints(k).center(1);
            %Note Orientation of Road
            ints(k).roads(j).orientation = 'vertical';
            %Road Starting Point and Ending Point
            ints(k).roads(j).starting_point = ints(k).center(2) - ...
                ints(k).roads(j).num_lanes*ints(k).roads(j).lane_width;
            ints(k).roads(j).ending_point = ints(k).roads(j).starting_point ...
                - ints(k).roads(j).length;
            %Define incoming lanes
            for i = 1:ints(k).roads(j).num_lanes
                ints(k).roads(j).lanes(i).direction = pi/2;
                ints(k).roads(j).lanes(i).center = ints(k).roads(j).center ...
                    + ints(k).roads(j).width/2 - i*ints(k).roads(j).lane_width ...
                    + ints(k).roads(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = ints(k).roads(j).num_lanes+1:2*ints(k).roads(j).num_lanes
                ints(k).roads(j).lanes(i).direction = 3*pi/2;
                ints(k).roads(j).lanes(i).center = ints(k).roads(j).center ...
                    + ints(k).roads(j).width/2 - i*ints(k).roads(j).lane_width ...
                    + ints(k).roads(j).lane_width/2;
            end
        %Define Road 2
        elseif j == 4
            %Road Center is a vector coordinate
            ints(k).roads(j).center = ints(k).center(2);
            %Note Orientation of Road
            ints(k).roads(j).orientation = 'horizontal';
            %Road Starting Point and Ending Point
            ints(k).roads(j).starting_point = ints(k).center(1) - ...
                ints(k).roads(j).num_lanes*ints(k).roads(j).lane_width;
            ints(k).roads(j).ending_point = ints(k).roads(j).starting_point ...
                - ints(k).roads(j).length;
            %Define incoming lanes
            for i = 1:ints(k).roads(j).num_lanes
                ints(k).roads(j).lanes(i).direction = 0;
                ints(k).roads(j).lanes(i).center = ints(k).roads(j).center ...
                    - ints(k).roads(j).width/2 + i*ints(k).roads(j).lane_width ...
                    - ints(k).roads(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = ints(k).roads(j).num_lanes+1:2*ints(k).roads(j).num_lanes
                ints(k).roads(j).lanes(i).direction = pi;
                ints(k).roads(j).lanes(i).center = ints(k).roads(j).center ...
                    - ints(k).roads(j).width/2 + i*ints(k).roads(j).lane_width ...
                    - ints(k).roads(j).lane_width/2;
            end
        end
    end
    
    % defines lane connections. Negative connection indicates in an
    % intersection
    num = ints(k).roads(1).num_lanes;
    ints(k).connections = zeros(8*num,2);
    
    if all_straight
        
        % straights
        for i = 1:num
            ints(k).connections(i,:) = [k, 6*num-i+1];
            ints(k).connections(2*num+i,:) = [k, 8*num-i+1];
            ints(k).connections(4*num+i,:) = [k, 2*num-i+1];
            ints(k).connections(6*num+i,:) = [k, 4*num-i+1];
        end
        
    else
    
        % right turns
        ints(k).connections(1,:) = [k, 8*num];
        ints(k).connections(2*num+1,:) = [k, 2*num];
        ints(k).connections(4*num+1,:) = [k, 4*num];
        ints(k).connections(6*num+1,:) = [k, 6*num];

        % left turns
        ints(k).connections(num,:) = [k, 3*num+1];
        ints(k).connections(3*num,:) = [k, 5*num+1];
        ints(k).connections(5*num,:) = [k, 7*num+1];
        ints(k).connections(7*num,:) = [k, num+1];

        % straights
        for i = 2:num-1
            ints(k).connections(i,:) = [k, 6*num-i+1];
            ints(k).connections(2*num+i,:) = [k, 8*num-i+1];
            ints(k).connections(4*num+i,:) = [k, 2*num-i+1];
            ints(k).connections(6*num+i,:) = [k, 4*num-i+1];
        end
    
    end
 
end

% defines lane connections across intersections
for i = 1:num
    ints(1).connections(3*num+i,:) = [2, 7*num+1-i];
    ints(2).connections(7*num+i,:) = [1, 3*num+1-i];
end


end