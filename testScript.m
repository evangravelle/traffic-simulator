clear; clc;
% create default Intersection
[inters] = makeIntersection2(); 

% draw Intersection
[FIG] = drawIntersection(inters);

% hold on to figure, future plots on same figure
hold on;

% declare vehicle structure
vehicle = struct;

% Spawn Vehicles
lambda = 2; num_roads = 4; num_lanes = 3;
[road,lane] = poissonSpawn(lambda, num_roads, num_lanes);
if isnan(road) == 0
    for i = 1:length(road)
        [vehicle] = makeVehicle(inters,vehicle, i, lane(i), road(i), false);
        vehicle(i).figure = drawVehicle(vehicle, i);
    end
end




