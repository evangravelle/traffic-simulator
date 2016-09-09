clear; clc; close all

% create default Intersection
[inters] = makeIntersection2(); 

% draw Intersection
[FIG] = drawIntersection(inters);

% hold on to figure, future plots on same figure
hold on;

% declare vehicle structure
vehicle = struct;

% initialize simulation parameters
rng(1000)
t = 0;
delta_t = .1;
phase_length = 35; % time of whole intersection cycle
num_iter = 1200;
gamma = 0.5; % coefficient in determining threshold for waiting
h = 0.1; % coefficient in weighting function
policy = 2; % 1 is cyclical policy, 2 is our policy
max_speed = 20; % speed limit of system
yellow_time = max_speed/4;
min_time = 5; % minimum time spent in a phase
switch_threshold = 2; % 1 means wait time must be double, 0 means greater

lambda = 1*delta_t; % spawn rate, average vehicles per second
num_roads = 4; % number of roads
num_lanes = 3; % number of lanes
% randomly choose roads and lanes (generally returns a vector)
[road,lane] = poissonSpawn(lambda, num_roads, num_lanes);
time_enter = 0;
% make and draw all Vehicles according to chosen roads and lanes
[vehicle]= drawAllVehicles(inters, vehicle, road, lane, time_enter, max_speed);
% This keeps track of last vehicle to spawn in each lane, to check for
% collisions
latest_spawn = zeros(num_roads,num_lanes);

% Play this mj2 file with VLC
vid_obj = VideoWriter('movie.avi','Archival');
vid_obj.FrameRate = 1/delta_t;
open(vid_obj);

% These parameters solve the equations for psi = 2 and T = 10
c = [.54 1.5 1.5 -1];
weight = @(t) c(1) * (t + c(2))^c(3) + c(4);

switch_time = Inf;
inters(1).green = [1 3];
previous_state = 1;
title_str = 'green light on vertical road';

% run simulation 
for t = delta_t*(1:num_iter)
    
    W = [0 0];
    if ~isempty(fieldnames(vehicle))
        for i = 1:length(vehicle)
            if (vehicle(i).time_enter ~= -1 && vehicle(i).time_leave == -1 && ismember(vehicle(i).lane,1:num_lanes))
                switch vehicle(i).road
                    case 1
                        W(1) = W(1) + weight(vehicle(i).wait);
                    case 2
                        W(2) = W(2) + weight(vehicle(i).wait);
                    case 3
                        W(1) = W(1) + weight(vehicle(i).wait);
                    case 4
                        W(2) = W(2) + weight(vehicle(i).wait);
                end
            end
        end
    end
    
    % Yellow light time needs to be function of max velocity! Not a
    % function of phase_length
    if policy == 1
        if mod(t,phase_length) < phase_length/2 - yellow_time
            inters(1).green = [1 3];
            title_str = 'green light on vertical road';
        elseif mod(t,phase_length) < phase_length/2
            inters(1).green = [];
            title_str = 'yellow light on vertical road';
        elseif mod(t,phase_length) < phase_length - yellow_time
            inters(1).green = [2 4];
            title_str = 'green light on horizontal road';
        else
            inters(1).green = [];
            title_str = 'yellow light on horizontal road';
        end
        
    elseif policy == 2 
        
        if switch_time < yellow_time
            inters(1).green = [];
            if previous_state == 1
                title_str = 'yellow light on horizontal road';
            elseif previous_state == 2
                title_str = 'yellow light on vertical road';
            end
        elseif switch_time < yellow_time + min_time
            if previous_state == 1
                title_str = 'green light on vertical road';
                inters(1).green = [1 3];
            elseif previous_state == 2
                title_str = 'green light on horizontal road';
                inters(1).green = [2 4];
            end
        else  % if switching is an option
            
            if previous_state == 2 && (W(1) - W(2))/W(2) > switch_threshold
                switch_time = 0;
                inters(1).green = [1 3];
                previous_state = 1;
            elseif previous_state == 1 && (W(2) - W(1))/W(1) > switch_threshold
                switch_time = 0;
                inters(1).green = [2 4];
                previous_state = 2;
            end
        end
        
    end
    title([sprintf('t = %3.f, ',t) title_str])
    text_box = uicontrol('style','text');
    if policy == 2
        text_str = ['Custom Wait Time Policy   ';
            '  vertical weight = ', sprintf('%6.2f',W(1));
            'horizontal weight = ', sprintf('%6.2f',W(2))];
    elseif policy == 1
        text_str = ['Fixed Cycle Policy        ';
            '  vertical weight = ', sprintf('%6.2f',W(1)); 
            'horizontal weight = ', sprintf('%6.2f',W(2))];
    else
        text_str = ['  vertical weight = ', sprintf('%6.2f',W(1)); 
            'horizontal weight = ', sprintf('%6.2f',W(2))];
    end
    set(text_box,'String',text_str)
    set(text_box,'Units','characters')
    set(text_box,'Position', [6 6 50 5])
    
    % set(textBox,'Position',[200 200 100 50])
    
    % if vehicle is nonempty, run dynamics, update wait, and draw vehicle
    if ~isempty(fieldnames(vehicle))
        vehicle = runDynamics(inters, vehicle, t, delta_t);
        for i = 1:length(vehicle)
            if vehicle(i).velocity <= gamma*vehicle(i).max_velocity
                vehicle(i).wait = vehicle(i).wait + delta_t;
            end
            if isfield(vehicle, 'figure')
                delete(vehicle(i).figure);
            end
            if (vehicle(i).time_leave == -1 && vehicle(i).time_enter ~= -1)
                vehicle(i).figure = drawVehicle(vehicle(i));
            end
        end
    end
    
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
    if ~isnan(road) % if spawned at least one
        for j = 1:length(road) % assign every car its road and lane
            % If the last vehicle to spawn in the lane is too close, don't
            % spawn
            if latest_spawn(road(j),lane(j)) == 0 || ...
              norm(vehicle(latest_spawn(road(j),lane(j))).position - ...
              vehicle(latest_spawn(road(j),lane(j))).starting_point, 2) > ...
              4*vehicle(latest_spawn(road(j),lane(j))).length
                [vehicle] = makeVehicle(inters, vehicle, (in_queue + j), lane(j), road(j), t, max_speed);
                latest_spawn(road(j),lane(j)) = in_queue + j;
            end
        end
    end
    
    switch_time = switch_time + delta_t;
end

close(vid_obj);

% Post processing
total_time = 0;
total_wait_time = 0;
total_weighted_wait_time = 0;
for i = 1:length(vehicle)
    time = vehicle(i).time_leave - vehicle(i).time_enter;
    if time > 0
        total_time = total_time + time;
    end
    total_wait_time = total_wait_time + vehicle(i).wait;
    total_weighted_wait_time = total_weighted_wait_time + weight(vehicle(i).wait);
end

% TO DO LIST
% All the random stuff mentioned in the code already
% Program motion in intersection
% Make stops more accurate, have vehicles correct at slow speed, or just lock into destination when close
% When extending to multiple intersections, have vehicle(i).wait reset when entering a new intersection
% Initialize vehicle structs, make it a fixed size
% Make an option to run without graphics
% Use tic toc to figure out where MATLAB bottlenecks already
% Make phase change trigger match LaTeX doc, use eta and check that W(1) > eta*W(2)