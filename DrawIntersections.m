% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function FIG = DrawIntersections(inter)
%% Draw Intersection
% Figure properties
FIG = figure;
axis([-1.2*inter(1).road(1).length 1.2*inter(1).road(1).length ...
 -1.2*inter(1).road(1).length 1.2*inter(1).road(1).length])
set(FIG, 'Position', [300 200 900 800])
axis off manual equal %turns axis off, equal length in both x and y direction
hold on
% plots a point to make the axis stay put in the movie
plot(inter.road(1).center + inter.road(1).length + inter.road(1).num_lanes + 10, ...
  inter.road(1).center + inter.road(1).length + inter.road(1).num_lanes + 10, 'w*');
plot(inter.road(1).center - inter.road(1).length - inter.road(1).num_lanes - 10, ...
  inter.road(1).center - inter.road(1).length - inter.road(1).num_lanes - 10, 'w*');

for i = 1:4
    hold on;
    if strcmp(inter.road(i).orientation,'vertical') == 1
        %Draw/Plot Vertical Center Divides
        plot([inter.road(i).center; inter.road(i).center],[inter.road(i). ...
            starting_point; inter.road(i).ending_point], 'Color', [1 .5 0], 'LineWidth', 2);
        %Draw/Plot Vertical Road Left Border
        plot([inter.road(i).center + inter.road(i).lane_width*inter.road(i).num_lanes; ...
            inter.road(i).center + inter.road(i).lane_width*inter.road(i).num_lanes],...
            [inter.road(i).starting_point; inter.road(i).ending_point], 'Color', 'k', 'LineWidth', 2);
        %Draw/Plot Vertical Road Right Border
        plot([inter.road(i).center - inter.road(i).lane_width*inter.road(i).num_lanes; ...
            inter.road(i).center - inter.road(i).lane_width*inter.road(i).num_lanes], ...
            [inter.road(i).starting_point; inter.road(i).ending_point], 'Color', 'k', 'LineWidth', 2);
        for j = 1:2*inter.road(i).num_lanes
            %Draw/Plot Vertical Incoming Lane Centers 
            plot([inter.road(i).lane(j).center; inter.road(i).lane(j).center],[inter.road(i). ...
            starting_point; inter.road(i).ending_point], '--', 'Color', 'w');
            %Draw/Plot Boaders of Boarder Lanes
            if any(j==inter.road(i).border_lanes)
                %Draw/Plot Horizontal Lane Left Border 
                plot([inter.road(i).lane(j).center + inter.road(i).lane_width/2; ...
                    inter.road(i).lane(j).center + inter.road(i).lane_width/2],...
                    [inter.road(i).starting_point; inter.road(i).ending_point], 'Color', 'w');
                %Draw/Plot Horizontal Lane Right Border 
                plot([inter.road(i).lane(j).center - inter.road(i).lane_width/2; ...
                    inter.road(i).lane(j).center - inter.road(i).lane_width/2],...
                    [inter.road(i).starting_point; inter.road(i).ending_point], 'Color', 'w'); 
            end
            %drawnow;
            %pause(0.5);
        end
    elseif strcmp(inter.road(i).orientation,'horizontal') == 1
        %Draw/Plot Horizontal Center Divides
        plot([inter.road(i).starting_point; inter.road(i).ending_point], ...
            [inter.road(i).center; inter.road(i).center], 'Color', [1 .5 0], 'LineWidth', 2);
        %Draw/Plot Horizontal Road Left Boarder
        plot([inter.road(i).starting_point; inter.road(i).ending_point],...
            [inter.road(i).center + inter.road(i).lane_width*inter.road(i).num_lanes; ...
            inter.road(i).center + inter.road(i).lane_width*inter.road(i).num_lanes], 'Color', 'k', 'LineWidth', 2);
        %Draw/Plot Horizontal Road Right Boarder
        plot([inter.road(i).starting_point; inter.road(i).ending_point],...
            [inter.road(i).center - inter.road(i).lane_width*inter.road(i).num_lanes; ...
            inter.road(i).center - inter.road(i).lane_width*inter.road(i).num_lanes], 'Color', 'k', 'LineWidth', 2);
        for j = 1:2*inter.road(i).num_lanes
            %Draw/Plot Horizontal Incoming Lane Center
            plot([inter.road(i).starting_point; inter.road(i).ending_point], ...
                [inter.road(i).lane(j).center; inter.road(i).lane(j).center], '--', 'Color', 'w');
            %Draw/Plot Boaders of Boarder Lanes
            if any(j==inter.road(i).border_lanes)
                %Draw/Plot Horizontal Lane Left Border 
                plot([inter.road(i).starting_point; inter.road(i).ending_point], ...
                    [inter.road(i).lane(j).center + inter.road(i).lane_width/2; ...
                    inter.road(i).lane(j).center + inter.road(i).lane_width/2], 'Color', 'w');
                %Draw/Plot Horizontal Lane Right Border 
                plot([inter.road(i).starting_point; inter.road(i).ending_point], ...
                    [inter.road(i).lane(j).center - inter.road(i).lane_width/2; ...
                    inter.road(i).lane(j).center - inter.road(i).lane_width/2], 'Color', 'w'); 
            end
            %drawnow;
            %pause(0.5);
        end
    end
    hold on;
end
% savefig(FIG,'FIG.fig');
end