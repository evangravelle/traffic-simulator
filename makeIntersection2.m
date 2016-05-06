function[inters, FIG] = makeIntersection2()
%% Declare structures
inters.road.lane = struct;
%% Make the Intersection
num_intersections = 1; %number of intersections
for k = 1:num_intersections
    inters(k).center = [50,107];
    for j = 1:4 % 4 roads
        inters(k).road(j).lane_width = 12; %width of each lane at intersection
        inters(k).road(j).length = 500; %length of each road
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
%% Draw Intersection
% Figure properties
FIG = figure;
axis off %turns axis off
axis equal  %makes axis equal length in both x and y direction

for i = 1:4
    hold on;
    if strcmp(inters.road(i).orientation,'vertical') == 1
        %Draw/Plot Vertical Center Divides
        plot([inters.road(i).center; inters.road(i).center],[inters.road(i). ...
            starting_point; inters.road(i).ending_point], 'Color', [1 .5 0], 'LineWidth', 2);
        %Draw/Plot Vertical Road Left Boarder
        plot([inters.road(i).center + inters.road(i).lane_width*inters.road(i).num_lanes; ...
            inters.road(i).center + inters.road(i).lane_width*inters.road(i).num_lanes],...
            [inters.road(i).starting_point; inters.road(i).ending_point], 'Color', 'k', 'LineWidth', 2);
        %Draw/Plot Vertical Road Right Boarder
        plot([inters.road(i).center - inters.road(i).lane_width*inters.road(i).num_lanes; ...
            inters.road(i).center - inters.road(i).lane_width*inters.road(i).num_lanes], ...
            [inters.road(i).starting_point; inters.road(i).ending_point], 'Color', 'k', 'LineWidth', 2);
        for j = 1:2*inters.road(i).num_lanes
            %Draw/Plot Vertical Incoming Lane Centers 
            plot([inters.road(i).lane(j).center; inters.road(i).lane(j).center],[inters.road(i). ...
            starting_point; inters.road(i).ending_point], '--', 'Color', 'w');
            %Draw/Plot Boaders of Boarder Lanes
            if any(j==inters.road(i).boarder_lanes)
                %Draw/Plot Horizontal Lane Left Border 
                plot([inters.road(i).lane(j).center + inters.road(i).lane_width/2; ...
                    inters.road(i).lane(j).center + inters.road(i).lane_width/2],...
                    [inters.road(i).starting_point; inters.road(i).ending_point], 'Color', 'w');
                %Draw/Plot Horizontal Lane Right Border 
                plot([inters.road(i).lane(j).center - inters.road(i).lane_width/2; ...
                    inters.road(i).lane(j).center - inters.road(i).lane_width/2],...
                    [inters.road(i).starting_point; inters.road(i).ending_point], 'Color', 'w'); 
            end
            %drawnow;
            %pause(0.5);
        end
    elseif strcmp(inters.road(i).orientation,'horizontal') == 1
        %Draw/Plot Horizontal Center Divides
        plot([inters.road(i).starting_point; inters.road(i).ending_point], ...
            [inters.road(i).center; inters.road(i).center], 'Color', [1 .5 0], 'LineWidth', 2);
        %Draw/Plot Horizontal Road Left Boarder
        plot([inters.road(i).starting_point; inters.road(i).ending_point],...
            [inters.road(i).center + inters.road(i).lane_width*inters.road(i).num_lanes; ...
            inters.road(i).center + inters.road(i).lane_width*inters.road(i).num_lanes], 'Color', 'k', 'LineWidth', 2);
        %Draw/Plot Horizontal Road Right Boarder
        plot([inters.road(i).starting_point; inters.road(i).ending_point],...
            [inters.road(i).center - inters.road(i).lane_width*inters.road(i).num_lanes; ...
            inters.road(i).center - inters.road(i).lane_width*inters.road(i).num_lanes], 'Color', 'k', 'LineWidth', 2);
        for j = 1:2*inters.road(i).num_lanes
            %Draw/Plot Horizontal Incoming Lane Center
            plot([inters.road(i).starting_point; inters.road(i).ending_point], ...
                [inters.road(i).lane(j).center; inters.road(i).lane(j).center], '--', 'Color', 'w');
            %Draw/Plot Boaders of Boarder Lanes
            if any(j==inters.road(i).boarder_lanes)
                %Draw/Plot Horizontal Lane Left Border 
                plot([inters.road(i).starting_point; inters.road(i).ending_point], ...
                    [inters.road(i).lane(j).center + inters.road(i).lane_width/2; ...
                    inters.road(i).lane(j).center + inters.road(i).lane_width/2], 'Color', 'w');
                %Draw/Plot Horizontal Lane Right Border 
                plot([inters.road(i).starting_point; inters.road(i).ending_point], ...
                    [inters.road(i).lane(j).center - inters.road(i).lane_width/2; ...
                    inters.road(i).lane(j).center - inters.road(i).lane_width/2], 'Color', 'w'); 
            end
            %drawnow;
            %pause(0.5);
        end
    end
    hold on;
end
savefig(FIG,'FIG.fig');
end
 



