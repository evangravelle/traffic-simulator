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
%         [vehicle2] = makeVehicle(inters2,vehicle2, i, lane(i), road(i), time_enter);
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
phase_length = 30; % time of whole intersection cycle
num_iter = 600;

lambda = 2*delta_t; % spawn rate, average vehicles per second
num_roads = 4; % number of roads
num_lanes = 3; % number of lanes
% randomly choose roads and lanes (generally returns a vector)
[road,lane] = poissonSpawn(lambda, num_roads, num_lanes);
time_enter = 0;
% make and draw all Vehicles according to chosen roads and lanes
[vehicle]= drawAllVehicles(inters, vehicle, road, lane, time_enter);
% This keeps track of last vehicle to spawn in each lane, to check for
% collisions
latest_spawn = zeros(num_roads,num_lanes);


% Play this mj2 file with VLC
vid_obj = VideoWriter('movie.avi','Archival');
vid_obj.FrameRate = 1/delta_t;
open(vid_obj);

% run simulation 
for t = delta_t*(1:num_iter)
    
    % Yellow light time needs to be function of max velocity! Not a
    % function of phase_length
    if mod(t,phase_length) < 2*phase_length/5
        inters(1).green = [1 3];
        title_str = 'green light on vertical road';
    elseif mod(t,phase_length) < phase_length/2
        inters(1).green = [];
        title_str = 'no green';
    elseif mod(t,phase_length) < 9*phase_length/10
        inters(1).green = [2 4];
        title_str = 'green light on horizontal road';
    else
        inters(1).green = [];
        title_str = 'no green';
    end
    title([sprintf('t = %3.f, ',t) title_str])
    
    % if vehicle is nonempty, run dynamics
    if ~isempty(fieldnames(vehicle))
        vehicle = runDynamics(inters, vehicle, t, delta_t);
        for i = 1:length(vehicle)
            if isfield(vehicle, 'figure')
                delete(vehicle(i).figure);
            end
            if (vehicle(i).time_leave == -1 && vehicle(i).time_enter ~= -1)
                vehicle(i).figure = drawVehicle(vehicle(i));
            end
        end
    end
    
    % Spawn vehicles at each time step
    % [road,lane] = poissonSpawn(lambda, num_roads, num_lanes); 
    % time_enter = 0;
    % make and draw all Vehicles according to chosen roads and lanes
    % [vehicle]= makeAllVehicles(inters, vehicle, road, lane, time_enter, t, false);
    
    pause(0.05)
    current_frame = getframe(gcf);
    writeVideo(vid_obj, current_frame);
    
    % Now spawn new vehicles
    [road,lane] = poissonSpawn(lambda, num_roads, num_lanes);
    
    if isempty(fieldnames(vehicle(1))) 
        in_queue = 0; % overwrites the empty vehicle
    else
        in_queue = length(vehicle); % count number of cars already in the intersection
    end
    if isnan(road) == 0 % if spawned at least one
        for j = 1:length(road) % assign every car its road and lane
            % If the last vehicle to spawn in the lane is too close, don't
            % spawn
            if latest_spawn(road(j),lane(j)) == 0 || ...
              norm(vehicle(latest_spawn(road(j),lane(j))).position - ...
              vehicle(latest_spawn(road(j),lane(j))).starting_point, 2) > ...
              4*vehicle(latest_spawn(road(j),lane(j))).length
                [vehicle] = makeVehicle(inters, vehicle, (in_queue + j), lane(j), road(j), t);
                latest_spawn(road(j),lane(j)) = in_queue + j;
            end
        end
    end
end

close(vid_obj);