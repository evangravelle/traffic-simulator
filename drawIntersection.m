function[FIG]=drawIntersection(inters)
%% Draw Intersection
% Figure properties
FIG = figure;
axis([-1.2*inters(1).road(1).length 1.2*inters(1).road(1).length ...
  -1.2*inters(1).road(1).length 1.2*inters(1).road(1).length])
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
            if any(j==inters.road(i).border_lanes)
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
            if any(j==inters.road(i).border_lanes)
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