clear; clc; close all

% %% Julio's Test
% 
% % create default Intersection
% [inters2] = makeIntersection2(); 
% 
% % draw Intersection
% [FIG2] = drawIntersection(inters2);
% 
% % hold on to figure, future plots on same figure
% hold on;
% 
% % declare vehicle structure
% vehicle2 = struct;
% 
% % Spawn Vehicles
% lambda = 2; road = 4; lane = 3;
% [road,lane] = poissonSpawn(lambda, road, lane);
% time_enter = 0;
% t = 0;
% if isnan(road) == 0
%     for i = 1:length(road)
%         [vehicle2] = makeVehicle(inters2,vehicle2, i, lane(i), road(i), time_enter, false);
%         vehicle2(i).figure = drawVehicle(vehicle2(i), t);
%     end
% end


%% Evan's Test

% create default Intersection
[inters] = makeIntersection2(); 

% draw Intersection
[FIG] = drawIntersection(inters);

% hold on to figure, future plots on same figure
hold on;

% declare vehicle structure
vehicle = struct;

% initialize simulation parameters
t = 0;
delta_t = .1;
num_iter = 100;

% % first vehicle
% i = 1; % vehicle number
% road = 4; % vehicle road
% lane = 3; % vehicle lane
% time_enter = 0;
% % here false stands for 'not empty'
% [vehicle] = makeVehicle(inters, vehicle, i, lane, road, time_enter, false);
% vehicle(i).figure = drawVehicle(vehicle(i), t);
% 
% % second vehicle
% i = 2; % vehicle number
% road = 1; % vehicle road
% lane = 2; % vehicle lane
% time_enter = 0;
% [vehicle] = makeVehicle(inters, vehicle, i, lane, road, time_enter, false);
% vehicle(i).figure = drawVehicle(vehicle(i), t);

%--------------------------------------------------------------------------
% SPAWN VEHICLES  !!!USE THIS INSTEAD IF YOU WANT TO SPAWN RANDOMLY!!!
lambda = 2; % spawn average rate
num_roads = 4; % number of roads
num_lanes = 3; % number of 
% radomly choose roads and lanes (generall returns a vector)
[road,lane] = poissonSpawn(lambda, num_roads, num_lanes); 
time_enter = 0;
% make and draw all Vehicles according to chosen roads and lanes
[vehicle]= drawAllVehicles(inters, vehicle, road, lane, time_enter, t, false);
% END OF SPAWNING
%--------------------------------------------------------------------------

%KEEP IN MIND THE REST OF THIS CODE MAY RETURN AN ERROR IF NO VEHICLES  WERE SPAWNED
%(if [road, lane] = NaN);

% run simulation 
for t = delta_t*(1:num_iter)
    vehicle = runDynamics(inters, vehicle, delta_t);
    for i = 1:length(vehicle)
        delete(vehicle(i).figure);
        vehicle(i).figure = drawVehicle(vehicle(i), t);
    end
    pause(delta_t)
end

