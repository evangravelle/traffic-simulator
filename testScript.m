% create default Intersection
[inters] = makeIntersection2(); 

% draw Intersection
[FIG] = drawIntersection(inters);

% hold on to figure, future plots on same figure
hold on;

% declare vehicle structure
vehicle = struct;

% make r roads and 6 lanes (in each direction) per road
num_lanes = 3;
num_roads = 4;

% first vehicle
i = 1; % vehicle number
% here false stands for 'not empty'
[vehicle] = makeVehicle(inters,vehicle, i, num_lanes, num_roads, false);
vehicle(i).figure = drawVehicle(vehicle, i);

% second vehicle
i = 2; % vehicle number
[vehicle] = makeVehicle(inters,vehicle, i, num_lanes, num_roads, false);
vehicle(i).figure = drawVehicle(vehicle, i);




