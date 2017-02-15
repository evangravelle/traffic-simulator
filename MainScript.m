% Written by Evan Gravelle and Julio Martinez
% 12/11/16
clear; clc; close all
% hold on;

% Initialize parameters
delta_t = .1;
num_iter = 600;
wait_thresh = 0.1; % number between 0 and 1, 0 means time is added once a vehicle is stopped, 1 means time is added after slowing from max
policy = 'custom'; % the options are 'custom' or 'cycle'
max_speed = 20; % speed limit of system
yellow_time = max_speed/4; % this is heuristic
phase_length = 30; % time of whole intersection cycle
min_time = 10; % minimum time spent in a phase
switch_threshold = 1; % 0 means wait time must be greater to switch, 1 means double
spawn_rate = .2; % average vehicles per second
spawn_type = 'poisson'; % 'poisson'
all_straight = true; % true if no turns exist
num_int = 2; % number of intersections
num_roads = 4; % number of roads
num_lanes = 3; % number of lanes
lane_width = 3.2;
lane_length = 150;
make_video = true;

if all_straight
    straight_list = 1:num_lanes;
    turn_radius = Inf*ones(num_lanes,1);
    turn_length = 2*num_lanes*lane_width*ones(num_lanes,1);
else
    straight_list = 2:num_lanes-1;
    turn_radius = [(lane_width/2) Inf (7*lane_width/2)];
    turn_length = [(pi/2)*(lane_width/2) 2*num_lanes*lane_width (pi/2)*(7*lane_width/2)];
end

ints = MakeIntersections(num_int, lane_width, lane_length, num_lanes, all_straight);
DrawIntersections(ints);
% hold on

rng(1000)
[ints_temp,roads_temp,lanes_temp] = SpawnVehicles(spawn_rate, num_int, num_roads, num_lanes, 0, delta_t, spawn_type);
time_enter = 0;
% make and draw all Vehicles according to chosen roads and lanes
vehicles = struct;
vehicles = DrawAllVehicles(ints, vehicles, ints_temp, roads_temp, lanes_temp, time_enter, max_speed);
% This keeps track of last vehicle to spawn in each lane, to check for
% collisions
latest_spawn = zeros(num_int, num_roads, num_lanes);

% Play this mj2 file with VLC
% vid_obj = VideoWriter('movie.avi','Archival');
if make_video
    vid_obj = VideoWriter('movie','MPEG-4');
    vid_obj.FrameRate = 1/delta_t;
    open(vid_obj)
end

% These parameters solve the equations for psi = 2 and T = 10
% c = [.54 1.5 1.5 -.95];
% W = @(t) c(1) * (t + c(2))^c(3) + c(4);
W = @(t) .05 * t^2;

switch_time = Inf*ones(num_int);
hnd = [];
hnd = DrawLights(ints, hnd);

switch_log1 = [];
switch_log2 = [];
weight = zeros(num_int,num_iter,2);
w_ind = 1;
% Run simulation 
for t = delta_t*(1:num_iter)
    
    % Calculates weight in each lane
    if ~isempty(fieldnames(vehicles))
        for v = 1:length(vehicles)
            if (vehicles(v).time_enter ~= -1 && vehicles(v).time_leave == -1 && ismember(vehicles(v).lane,1:num_lanes))
                if mod(vehicles(v).road, 2) == 1
                    weight(vehicles(v).int,w_ind,1) = weight(vehicles(v).int,w_ind,1) + W(vehicles(v).wait);
                else
                    weight(vehicles(v).int,w_ind,2) = weight(vehicles(v).int,w_ind,2) + W(vehicles(v).wait);
                end
            end
        end
    end
    
    % Yellow light time needs to be function of max velocity! Not a
    % function of phase_length
    for k = 1:length(ints)
        if strcmp(policy, 'cycle')
            if mod(t,phase_length) < phase_length/2 - yellow_time
                if ~strcmp(ints(k).lights, 'grgr')
                    ints(k).lights = 'grgr';
                end
            elseif mod(t,phase_length) < phase_length/2
                if ~strcmp(ints(k).lights, 'yryr')
                    ints(k).lights = 'yryr';
                end
            elseif mod(t,phase_length) < phase_length - yellow_time
                if ~strcmp(ints(k).lights, 'rgrg')
                    ints(k).lights = 'rgrg';
                end
            else
                if ~strcmp(ints(k).lights, 'ygyg')
                    ints(k).lights = 'ygyg';
                end
            end
            hnd = DrawLights(ints, hnd);
            
        elseif strcmp(policy, 'custom')
            % if light is yellow
            if switch_time(k) < yellow_time
%                 if strcmp(ints(k).lights, 'grgr')
%                     if ~strcmp(ints(k).lights, 'ryry')
%                         ints(k).lights = 'ryry';
%                         hnd = DrawLights(ints, hnd);
%                     end
%                 elseif previous_state == 2
%                     if ~strcmp(ints(k).lights, 'yryr')
%                         ints(k).lights = 'yryr';
%                         hnd = DrawLights(ints, hnd);
%                     end
%                 end
            % if stuck in green
            elseif switch_time(k) < yellow_time + min_time
                if strcmp(ints(k).lights,'yryr')
                    ints(k).lights = 'rgrg';
                    hnd = DrawLights(ints, hnd);
                elseif strcmp(ints(k).lights,'ryry')
                    ints(k).lights = 'grgr';
                    hnd = DrawLights(ints, hnd);
                end
            else  % if switching is an option
                if strcmp(ints(k).lights,'grgr') && (weight(k,w_ind,2) - weight(k,w_ind,1))/weight(k,w_ind,1) > switch_threshold
                    switch_time(k) = 0;
                    if k == 1
                        switch_log1 = [switch_log1, t];
                    elseif k == 2
                        switch_log2 = [switch_log2, t];
                    end
                    ints(k).lights = 'yryr';
                    hnd = DrawLights(ints, hnd);
                elseif strcmp(ints(k).lights,'rgrg') && (weight(k,w_ind,1) - weight(k,w_ind,2))/weight(k,w_ind,2) > switch_threshold
                    switch_time(k) = 0;
                    if k == 1
                        switch_log1 = [switch_log1, t];
                    elseif k == 2
                        switch_log2 = [switch_log2, t];
                    end
                    ints(k).lights = 'ryry';
                    hnd = DrawLights(ints, hnd);
                end
            end
        end
    end

    % INCOMPLETE, NEED TO ACCOUNT FOR MULTIPLE INTERSECTIONS
    title_str = sprintf('Time = %.2f', t);
    title(title_str)
%     text_box = uicontrol('style','text');
%     if strcmp(policy, 'custom')
%         text_str = ['Custom Wait Time Policy      '];
%     elseif strcmp(policy, 'cycle')
%         text_str = ['Fixed Cycle Policy           '];
%     end
%     text_str = [text_str;
%       '  vertical weight1 = ', sprintf('%8.2f',weight(1,w_ind,1)); 
%       'horizontal weight1 = ', sprintf('%8.2f',weight(1,w_ind,2))];
%     if length(ints) == 2
%         text_str = [text_str;
%           '  vertical weight2 = ', sprintf('%8.2f',weight(2,w_ind,1));
%           'horizontal weight2 = ', sprintf('%8.2f',weight(2,w_ind,2))];
%     end
%     set(text_box,'String',text_str)
%     set(text_box,'Units','characters')
%     set(text_box,'Position', [70 15 50 8])
    
    % if vehicle is nonempty, run dynamics, update wait, and draw vehicle
    if ~isempty(fieldnames(vehicles))
        vehicles = RunDynamics(ints, vehicles, straight_list, turn_radius, turn_length, wait_thresh, yellow_time, t, delta_t);
        for v = 1:length(vehicles)
            if vehicles(v).velocity <= wait_thresh*vehicles(v).max_velocity
                vehicles(v).wait = vehicles(v).wait + delta_t;
            end
            if isfield(vehicles, 'figure')
                delete(vehicles(v).figure);
            end
            if (vehicles(v).time_leave == -1 && vehicles(v).time_enter ~= -1)
                vehicles(v).figure = DrawVehicle(vehicles(v));
            end
        end
    end
    
    if make_video
        pause(0.03)
        current_frame = getframe(gcf);
        writeVideo(vid_obj, current_frame);
    end
    
    % Now spawn new vehicles
    [ints_temp,roads_temp,lanes_temp] = SpawnVehicles(spawn_rate, num_int, num_roads, num_lanes, t, delta_t, spawn_type);
    if isempty(fieldnames(vehicles(1))) 
        ctr = 0; % overwrites the empty vehicle
    else
        ctr = length(vehicles); % count number of cars already spawned
    end
    if ~isnan(roads_temp) % if spawned at least one
        for s = 1:length(roads_temp) % assign every car its road and lane
            % If the last vehicle to spawn in the lane is too close, dont
            % spawn
            if latest_spawn(ints_temp(s),roads_temp(s),lanes_temp(s)) == 0 || ...
              norm(vehicles(latest_spawn(ints_temp(s),roads_temp(s),lanes_temp(s))).position - ...
              vehicles(latest_spawn(ints_temp(s),roads_temp(s),lanes_temp(s))).starting_point, 2) > ...
              4*vehicles(latest_spawn(ints_temp(s),roads_temp(s),lanes_temp(s))).length
                vehicles = MakeVehicle(ints, vehicles, (ctr + 1), ints_temp(s), roads_temp(s), lanes_temp(s), t, max_speed);
                latest_spawn(ints_temp(s),roads_temp(s),lanes_temp(s)) = ctr + 1;
                ctr = ctr + 1;
            end
        end
    end
    
    if mod(t, delta_t*num_iter/10) == 0
        fprintf('Time = %f\n', t);
    end

    switch_time = switch_time + delta_t;
    w_ind = w_ind + 1;
end

if make_video
    close(vid_obj);
    close(gcf);
end
    
% Post processing
total_time = 0;
total_wait_time = 0;
total_weighted_wait_time = 0;
for v = 1:length(vehicles)
    time = vehicles(v).time_leave - vehicles(v).time_enter;
    if time > 0
        total_time = total_time + time;
    end
    total_wait_time = total_wait_time + vehicles(v).wait;
    total_weighted_wait_time = total_weighted_wait_time + W(vehicles(v).wait);
end

figure
hold on
plot(delta_t*(0:num_iter-1), weight(1,:,1), 'r--')
plot(delta_t*(0:num_iter-1), weight(1,:,2), 'b')
plot(delta_t*(0:num_iter-1), weight(2,:,1), 'r--')
plot(delta_t*(0:num_iter-1), weight(2,:,2), 'b')
plot(switch_log1, zeros(length(switch_log1),1), '*')
plot(switch_log2, zeros(length(switch_log2),1), '*')
xlabel('Time (s)')
ylabel('Weight')
title('Road weights')
legend('NS1','EW1','NS2', 'EW2')
saveas(gcf, 'weight_plot', 'png')

% TO DO LIST
% All the random stuff mentioned in the code already
% Program motion in intersection
% Make stops more accurate, have vehicles correct at slow speed, or just lock into destination when close
% When extending to multiple intersections, have vehicle(i).wait reset when entering a new intersection
% Initialize vehicle structs, make it a fixed size
% Make an option to run without graphics
% Make phase change trigger match LaTeX doc, use eta and check that W(1) > eta*W(2)