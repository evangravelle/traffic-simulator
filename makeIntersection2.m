function[inters] = makeIntersection2()
%% Declare structures
inters.road.lane = struct;
%% Make the Intersection
num_intersections = 1; %number of intersections
for k = 1:num_intersections
    inters(k).center = [0,0];
    for j = 1:4 % 4 roads
        inters(k).road(j).lane_width = 12; %width of each lane at intersection
        inters(k).road(j).length = 100; %length of each road
        inters(k).road(j).num_lanes = 3; %number of lanes in each direction
        inters(k).road(j).width = 2*(inters(k).road(j).lane_width)*(inters(k).road(j).num_lanes);
        inters(k).road(j).boarder_lanes = [2,5]; %lanes for which we will draw a border
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
                inters(k).road(j).lane(i).direction = 'incoming';
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    - inters(k).road(j).width/2 + i*inters(k).road(j).lane_width ...
                    - inters(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = inters(k).road(j).num_lanes+1:2*inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = 'outgoing';
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
                inters(k).road(j).lane(i).direction = 'incoming';
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    + inters(k).road(j).width/2 - i*inters(k).road(j).lane_width ...
                    + inters(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = inters(k).road(j).num_lanes+1:2*inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = 'outgoing';
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    + inters(k).road(j).width/2 - i*inters(k).road(j).lane_width ...
                    + inters(k).road(j).lane_width/2;
            end
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
                inters(k).road(j).lane(i).direction = 'incoming';
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    + inters(k).road(j).width/2 - i*inters(k).road(j).lane_width ...
                    + inters(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = inters(k).road(j).num_lanes+1:2*inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = 'outgoing';
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    + inters(k).road(j).width/2 - i*inters(k).road(j).lane_width ...
                    + inters(k).road(j).lane_width/2;
            end
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
                inters(k).road(j).lane(i).direction = 'incoming';
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    - inters(k).road(j).width/2 + i*inters(k).road(j).lane_width ...
                    - inters(k).road(j).lane_width/2;
            end
            %Define outgoing lanes
            for i = inters(k).road(j).num_lanes:2*inters(k).road(j).num_lanes
                inters(k).road(j).lane(i).direction = 'outgoing';
                inters(k).road(j).lane(i).center = inters(k).road(j).center ...
                    - inters(k).road(j).width/2 + i*inters(k).road(j).lane_width ...
                    - inters(k).road(j).lane_width/2;
            end
        end
    end
end
end
 



