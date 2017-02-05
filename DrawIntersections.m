% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function fig = DrawIntersections(ints)
%% Draw Intersection
% Figure properties
last_int = length(ints);
fig = figure;
axis([ints(1).center(1)-1.2*ints(1).roads(1).length, ...
  ints(last_int).center(1)+1.2*ints(last_int).roads(1).length, ...
 -1.2*ints(1).road(1).length, 1.2*ints(1).roads(1).length])
set(fig, 'Position', [300 200 900 800])
axis off manual equal %turns axis off, equal length in both x and y direction
hold on
% plots a point to make the axis stay put in the movie
plot(ints(last_int).center(1) + ints(last_int).roads(1).length + ints(last_int).roads(1).num_lanes + 10, ...
  ints(last_int).center(2) + ints(last_int).roads(1).length + ints.roads(1).num_lanes + 10, 'w*');
plot(ints(1).center(1) - ints(1).roads(1).length - ints(1).roads(1).num_lanes - 10, ...
  ints(1).center(2) - ints(1).roads(1).length - ints(1).roads(1).num_lanes - 10, 'w*');

for k = 1:last_int
    for j = 1:4
        if strcmp(ints(k).roads(j).orientation,'vertical') == 1
            %Draw Vertical Center Divides
            plot([ints(k).roads(j).center; ints(k).roads(j).center],[ints(k).roads(j). ...
                starting_point; ints(k).roads(j).ending_point], 'Color', [1 .5 0], 'LineWidth', 2);
            %Draw Vertical Road Left Border
            plot([ints(k).roads(j).center + ints(k).roads(j).lane_width*ints(k).roads(j).num_lanes; ...
                ints(k).roads(j).center + ints(k).roads(j).lane_width*ints(k).roads(j).num_lanes],...
                [ints(k).roads(j).starting_point; ints(k).roads(j).ending_point], 'Color', 'k', 'LineWidth', 2);
            %Draw Vertical Road Right Border
            plot([ints(k).roads(j).center - ints(k).roads(j).lane_width*ints(k).roads(j).num_lanes; ...
                ints(k).roads(j).center - ints(k).roads(j).lane_width*ints(k).roads(j).num_lanes], ...
                [ints(k).roads(j).starting_point; ints(k).roads(j).ending_point], 'Color', 'k', 'LineWidth', 2);
            for i = 1:2*ints.roads(j).num_lanes
                %Draw Vertical Incoming Lane Centers
                plot([ints(k).roads(j).lanes(i).center; ints(k).roads(j).lanes(i).center],[ints(k).roads(j). ...
                    starting_point; ints(k).roads(j).ending_point], '--', 'Color', 'w');
                %Draw Borders of Border Lanes
                if any(i==ints(k).roads(j).border_lanes)
                    %Draw Horizontal Lane Left Border
                    plot([ints(k).roads(j).lanes(i).center + ints(k).roads(j).lane_width/2; ...
                        ints(k).roads(j).lanes(i).center + ints(k).roads(j).lane_width/2],...
                        [ints(k).roads(j).starting_point; ints(k).roads(j).ending_point], 'Color', 'w');
                    %Draw Horizontal Lane Right Border
                    plot([ints(k).roads(j).lanes(i).center - ints(k).roads(j).lane_width/2; ...
                        ints(k).roads(j).lanes(i).center - ints(k).roads(j).lane_width/2],...
                        [ints(k).roads(j).starting_point; ints(k).roads(j).ending_point], 'Color', 'w');
                end
                %drawnow;
                %pause(0.5);
            end
        elseif strcmp(ints(k).roads(j).orientation,'horizontal') == 1
            %Draw Horizontal Center Divides
            plot([ints(k).roads(j).starting_point; ints(k).roads(j).ending_point], ...
                [ints(k).roads(j).center; ints(k).roads(j).center], 'Color', [1 .5 0], 'LineWidth', 2);
            %Draw Horizontal Road Left Border
            plot([ints(k).roads(j).starting_point; ints(k).roads(j).ending_point],...
                [ints(k).roads(j).center + ints(k).roads(j).lane_width*ints(k).roads(j).num_lanes; ...
                ints(k).roads(j).center + ints(k).roads(j).lane_width*ints(k).roads(j).num_lanes], 'Color', 'k', 'LineWidth', 2);
            %Draw Horizontal Road Right Border
            plot([ints(k).roads(j).starting_point; ints.roads(j).ending_point],...
                [ints(k).roads(j).center - ints(k).roads(j).lane_width*ints(k).roads(j).num_lanes; ...
                ints(k).roads(j).center - ints(k).roads(j).lane_width*ints(k).roads(j).num_lanes], 'Color', 'k', 'LineWidth', 2);
            for i = 1:2*ints(k).roads(j).num_lanes
                %Draw Horizontal Incoming Lane Center
                plot([ints(k).roads(j).starting_point; ints(k).roads(j).ending_point], ...
                    [ints(k).roads(j).lane(k).center; ints(k).roads(j).lane(k).center], '--', 'Color', 'w');
                %Draw Boders of Border Lanes
                if any(i==ints.roads(j).border_lanes)
                    %Draw Horizontal Lane Left Border
                    plot([ints(k).roads(j).starting_point; ints(k).roads(j).ending_point], ...
                        [ints(k).roads(j).lanes(i).center + ints(k).roads(j).lane_width/2; ...
                        ints(k).roads(j).lanes(i).center + ints(k).roads(j).lane_width/2], 'Color', 'w');
                    %Draw Horizontal Lane Right Border
                    plot([ints(k).roads(j).starting_point; ints(k).roads(j).ending_point], ...
                        [ints(k).roads(j).lanes(i).center - ints(k).roads(j).lane_width/2; ...
                        ints(k).roads(j).lanes(i).center - ints(k).roads(j).lane_width/2], 'Color', 'w');
                end
                %drawnow;
                %pause(0.5);
            end
        end
    end
end
% savefig(fig,'FIG.fig');
end