% Written by Evan Gravelle and Julio Martinez
% 12/11/16
clear; clc; close all
% hold on;

% Initialize parameters
delta_t = .1;
num_iter = 1200;
wait_thresh = 0.1; % number between 0 and 1, 0 means time is added once a vehicle is stopped, 1 means time is added after slowing from max
policy = 'custom'; % the options are 'custom' or 'cycle'
max_speed = 20; % speed limit of system
yellow_time = max_speed/4; % this is heuristic
stop_time = 5; % given by deltaV/minAccel
phase_length = 60; % time of whole intersection cycle
min_time = 10; % minimum time spent in a phase
min_veh = 7;
alpha = 10; % coefficient on coordination term
switch_threshold = 1; % 0 means wait time must be greater to switch, 1 means double
spawn_rate = 1.5; % average vehicles per second
spawn_type = 'poisson'; % 'poisson'
all_straight = false; % true if no turns exist
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
    init_lights = 'grgr';
else
    straight_list = 2:num_lanes-1;
    turn_radius = [.5*lane_width, Inf, (num_lanes+.5)*lane_width];
    turn_length = [pi/2*.5*lane_width, 2*num_lanes*lane_width, pi/2*(num_lanes+.5)*lane_width];
    % each element describes which phase is compatible by holding one direction constant.
    % row = joint phase number, column = which lane is constant
    phases_compat_inds = [2 3;1 4;1 4;2 3;6 7;5 8;5 8;6 7]; 
    phases = [2 6;1 2;5 6;1 5;4 8;3 4;7 8;3 7];
    init_lights = 'rgrrrgrr';
end

ints = MakeIntersections(num_int, lane_width, lane_length, num_lanes, init_lights, all_straight);
DrawIntersections(ints);
% hold on

rng(10)
[ints_temp,roads_temp,lanes_temp] = SpawnVehicles(spawn_rate, num_int, num_roads, num_lanes, 0, delta_t, spawn_type);
time_enter = 0;
% make and draw all Vehicles according to chosen roads and lanes
vehicles = struct;
vehicles = DrawAllVehicles(ints, vehicles, ints_temp, roads_temp, lanes_temp, time_enter, max_speed);
% This keeps track of last vehicle to spawn in each lane, to check for
% collisions
latest_spawn = zeros(num_int, num_roads, num_lanes);
queue_lengths = zeros(num_int, num_roads, num_lanes, num_iter);
packets = [];
int_dist = ints(2).center(1);
max_accel = 1.8;
T = 22; % (int_dist-.5*max_speed^2/max_accel)/max_speed; % time for platoon to reach new intersection
min_times = min_time*ones(num_int,1);

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
% W = @(t) .05 * (t^2 + t);
% Functions
W = @(t) .05 * t.^2;
B = @(alp,E,z,zeta,g) alp*E*max([0, min([z/zeta+1,1,g/zeta,-z/zeta+g/zeta])]);

switch_time = Inf*ones(num_int,1);
hnd = [];
% hnd = DrawLights(ints, hnd);
switch_log1 = [];
switch_log2 = [];
if all_straight
    num_w = 2;
else
    num_w = 8;
end
weights = zeros(num_int,num_iter,num_w);
added_weights = zeros(num_int,num_iter,num_w);

w_ind = 1;
% Run simulation
for t = delta_t*(1:num_iter)
    
    % Calculates weights in each lane
    if ~isempty(fieldnames(vehicles))
        [weights(:,w_ind,:), added_weights(:,w_ind,:)] = CalcWeights(vehicles, ...
          num_int, num_w, num_lanes, wait_thresh, packets, t, yellow_time, stop_time, alpha, min_time, W, B);
    end
    
    % Yellow light time needs to be function of max velocity! Not a
    % function of phase_length
    for k = 1:length(ints)
        if strcmp(policy, 'cycle') && all_straight == true
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
            
        elseif strcmp(policy, 'cycle') && all_straight == false
            if mod(t,phase_length) < phase_length/4 - yellow_time
                ints(k).lights = 'grrrgrrr';
            elseif mod(t,phase_length) < phase_length/4
                ints(k).lights = 'yrrryrrr';
            elseif mod(t,phase_length) < phase_length/2 - yellow_time
                ints(k).lights = 'rgrrrgrr';
            elseif mod(t,phase_length) < phase_length/2
                ints(k).lights = 'ryrrryrr';
            elseif mod(t,phase_length) < 3*phase_length/4 - yellow_time
                ints(k).lights = 'rrgrrrgr';
            elseif mod(t,phase_length) < 3*phase_length/4
                ints(k).lights = 'rryrrryr';
            elseif mod(t,phase_length) < phase_length - yellow_time
                ints(k).lights = 'rrrgrrrg';
            elseif mod(t,phase_length) < phase_length
                ints(k).lights = 'rrryrrry';
            end
            
        elseif strcmp(policy, 'custom') && all_straight == true
            % if light is yellow
            if switch_time(k) < yellow_time
                % do nothing
            % if stuck in green
            elseif switch_time(k) < yellow_time + min_times(k)
                if strcmp(ints(k).lights,'yryr')
                    ints(k).lights = 'rgrg';
                    hnd = DrawLights(ints, hnd);
                elseif strcmp(ints(k).lights,'ryry')
                    ints(k).lights = 'grgr';
                    hnd = DrawLights(ints, hnd);
                end
            % if switching is an option
            else
                if strcmp(ints(k).lights,'grgr') && (weights(k,w_ind,2) + added_weights(k,w_ind,2) - ...
                  weights(k,w_ind,1) - added_weights(k,w_ind,1)) / ...
                  (weights(k,w_ind,1) + added_weights(k,w_ind,1)) > switch_threshold
                    switch_time(k) = 0;
                    if k == 1
                        switch_log1 = [switch_log1, t];
                    elseif k == 2
                        switch_log2 = [switch_log2, t];
                    end
                    ints(k).lights = 'yryr';
                    hnd = DrawLights(ints, hnd);
                elseif strcmp(ints(k).lights,'rgrg') && (weights(k,w_ind,1) + added_weights(k,w_ind,1) - ...
                  weights(k,w_ind,2) - added_weights(k,w_ind,2)) / ...
                  (weights(k,w_ind,2) + added_weights(k,w_ind,2)) > switch_threshold
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
            
        elseif strcmp(policy, 'custom') && all_straight == false
            % if stuck in yellow
            if switch_time(k) < yellow_time
                % do nothing
            % if stuck in green
            elseif switch_time(k) < yellow_time + min_times(k)
                inds = strfind(ints(k).lights, 'y');
                if ~isempty(inds)
                    ints(k).lights(inds) = 'r';
                    ints(k).lights(to_switch_to(k,:)) = 'g';
                    % hnd = DrawLights(ints, hnd);
                end
            % if switching is an option
            else
                inds = strfind(ints(k).lights, 'g');
                [~, current_phase_ind] = ismember(inds, phases, 'rows');
                phase_weights = zeros(num_w,1);
                for tmp = 1:num_w
                    phase_weights(tmp) = sum(weights(k,w_ind,phases(tmp,:))) + sum(added_weights(k,w_ind,phases(tmp,:)));
                end
                [max_phase_weight, max_ind] = max(phase_weights);
                current_phase = phases(current_phase_ind,:);
                current_weight = phase_weights(current_phase_ind);
                neighbor_phase_inds = phases_compat_inds(current_phase_ind,:);
                neighbor_phases = phases(neighbor_phase_inds,:);
                neighbor_weights = phase_weights(neighbor_phase_inds);
                if (max_phase_weight - current_weight)/current_weight > switch_threshold
                    new_phase = phases(max_ind,:);
                    fprintf('t = %f, int = %d, current_phase = [%d %d], new_phase = [%d %d]\n', t, k, ...
                      current_phase(1), current_phase(2), new_phase(1), new_phase(2))
                    fprintf('max_phase_weight = %f, current_weight = %f\n', max_phase_weight, current_weight)
                    min_times = calcMinTimes(new_phase, num_lanes, queue_lengths, k, ... 
                      w_ind, min_times, min_time, packets, yellow_time, t);
                    to_switch_to(k,:) = new_phase;
                    switch_time(k) = 0;
                    if k == 1
                        switch_log1 = [switch_log1, t];
                    elseif k == 2
                        switch_log2 = [switch_log2, t];
                    end
                    if ~ismember(phases(current_phase_ind,1), phases(max_ind,:))
                        ints(k).lights(phases(current_phase_ind,1)) = 'y';
                    end
                    if ~ismember(phases(current_phase_ind,2), phases(max_ind,:))
                        ints(k).lights(phases(current_phase_ind,2)) = 'y';
                    end
                    % hnd = DrawLights(ints, hnd);
                elseif (neighbor_weights(1) - current_weight)/current_weight > .5*switch_threshold
                    new_phase = setdiff(neighbor_phases(1,:),current_phase)
                    fprintf('t = %f, int = %d, current_phase = %d, new_phase = %d\n', t, k, phases(current_phase,:), new_phase)
                    fprintf('neighbor_phase_weight = %f, current_weight = %f\n', neighbor_weights(1), current_weight)
                    min_times = calcMinTimes(new_phase, num_lanes, queue_lengths, k, ...
                      w_ind, min_times, min_time, packets, yellow_time, t);
                    to_switch_to(k,:) = new_phase;
                    switch_time(k) = 0;
                    if k == 1
                        switch_log1 = [switch_log1, t];
                    elseif k == 2
                        switch_log2 = [switch_log2, t];
                    end
                    ints(k).lights(setdiff(current_phase,neighbor_phases(1,:))) = 'y';
                    % hnd = DrawLights(ints, hnd);
                elseif (neighbor_weights(2) - current_weight)/current_weight > .5*switch_threshold
                    new_phase = setdiff(neighbor_phases(2,:),current_phase)
                    fprintf('t = %f, int = %d, current_phase = %d, new_phase = %d\n', t, k, phases(current_phase,:), new_phase)
                    fprintf('neighbor_phase_weight = %f, current_weight = %f\n', neighbor_weights(2), current_weight)
                    min_times = calcMinTimes(new_phase, num_lanes, queue_lengths, k, ...
                      w_ind, min_times, min_time, packets, yellow_time, t);
                    to_switch_to(k,:) = new_phase;
                    switch_time(k) = 0;
                    if k == 1
                        switch_log1 = [switch_log1, t];
                    elseif k == 2
                        switch_log2 = [switch_log2, t];
                    end
                    ints(k).lights(setdiff(current_phase,neighbor_phases(2,:))) = 'y';
                    % hnd = DrawLights(ints, hnd);
                end
            end
        end
        
        % if switching to enable flow toward another intersection, create packet
        % packet contains source intersection, number of vehicles, and 
        if k == 1 && abs(switch_time(k)-yellow_time) <= .001 && ismember(1, to_switch_to(k,:)) && queue_lengths(k,1,3,w_ind-1) > 0
            packets = [packets; k, min([min_veh,queue_lengths(k,1,3,w_ind-1)]), t + T];
        elseif k == 1 && abs(switch_time(k)-yellow_time) <= .001 && ismember(6, to_switch_to(k,:)) && sum(queue_lengths(k,3,1,w_ind-1)) > 0
            packets = [packets; k, min([min_veh,sum(queue_lengths(k,3,1,w_ind-1))]), t + T];
        elseif k == 1 && abs(switch_time(k)-yellow_time) <= .001 && ismember(8, to_switch_to(k,:)) && sum(queue_lengths(k,4,2,w_ind-1)) > 0
            packets = [packets; k, min([min_veh,sum(queue_lengths(k,4,2,w_ind-1))]), t + T];
        end
        if k == 2 && abs(switch_time(k)-yellow_time) <= .001 && ismember(2,to_switch_to(k,:)) && sum(queue_lengths(k,1,1,w_ind-1)) > 0
            packets = [packets; k, min([min_veh,sum(queue_lengths(k,1,1,w_ind-1))]), t + T];
        elseif k == 2 && abs(switch_time(k)-yellow_time) <= .001 && ismember(4,to_switch_to(k,:)) && sum(queue_lengths(k,2,2,w_ind-1)) > 0
            packets = [packets; k, min([min_veh,sum(queue_lengths(k,2,2,w_ind-1))]), t + T];
        elseif k == 2 && abs(switch_time(k)-yellow_time) <= .001 && ismember(5,to_switch_to(k,:)) && queue_lengths(k,3,3,w_ind-1) > 0
            packets = [packets; k, min([min_veh,queue_lengths(k,3,3,w_ind-1)]), t + T];
        end
    end
    
    if mod(t, 1) == 0
        % fprintf('Int1 = %s\n', ints(1).lights)
        % fprintf('Int2 = %s\n', ints(2).lights)
    end
    
    title_str = sprintf('Time = %.2f', t);
    title(title_str)
    text_box = uicontrol('style','text');
    if strcmp(policy, 'custom')
        text_str = ['Custom Policy       ', ints(1).lights, '                   ', ints(2).lights, '      '];
    elseif strcmp(policy, 'cycle')
        text_str = ['Cycle Policy        ', ints(1).lights, '                   ', ints(2).lights, '      '];
    end
    % disp(length(text_str))
    % disp(length(['Int1=', sprintf('%7.1f',weights(1,w_ind,:))]))
    if all_straight
        text_str = [text_str;
            '  vertical weight1 = ', sprintf('%8.2f',weights(1,w_ind,1));
            'horizontal weight1 = ', sprintf('%8.2f',weights(1,w_ind,2))];
        if length(ints) == 2
            text_str = [text_str;
                '  vertical weight2 = ', sprintf('%8.2f',weights(2,w_ind,1));
                'horizontal weight2 = ', sprintf('%8.2f',weights(2,w_ind,2))];
        end
        set(text_box,'String',text_str)
        set(text_box,'Units','characters')
        set(text_box,'Position', [70 15 50 8])
    else
        text_str = [text_str; 'Int1=', sprintf('%7.1f',weights(1,w_ind,:)+added_weights(1,w_ind,:))];
        if length(ints) == 2
            text_str = [text_str; 'Int2=', sprintf('%7.1f',weights(2,w_ind,:)+added_weights(2,w_ind,:))];
        end
        set(text_box,'String',text_str)
        set(text_box,'Units','characters')
        if num_int == 1
            set(text_box,'Position', [25 15 60 8])
        else
            set(text_box,'Position', [63 15 60 8])
        end
    end
    
    % if vehicle is nonempty, run dynamics, update wait, and draw vehicle
    if ~isempty(fieldnames(vehicles))
        vehicles = RunDynamics(ints, vehicles, straight_list, turn_radius, turn_length, wait_thresh, yellow_time, t, delta_t);
        for v = 1:length(vehicles)
            if vehicles(v).velocity <= wait_thresh*vehicles(v).max_velocity
                queue_lengths(vehicles(v).int, vehicles(v).road, abs(vehicles(v).lane), w_ind) = ...
                  queue_lengths(vehicles(v).int, vehicles(v).road, abs(vehicles(v).lane), w_ind) + 1;
            end
            if isfield(vehicles, 'figure')
                delete(vehicles(v).figure);
            end
            if (vehicles(v).time_leave == -1 && vehicles(v).time_enter ~= -1)
                vehicles(v).figure = DrawVehicle(vehicles(v));
            end
        end
    end
    % disp(reshape(queue_lengths(:, :, :, w_ind),1,24))
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
              2*vehicles(latest_spawn(ints_temp(s),roads_temp(s),lanes_temp(s))).length
                vehicles = MakeVehicle(ints, vehicles, (ctr + 1), ints_temp(s), roads_temp(s), lanes_temp(s), t, max_speed);
                latest_spawn(ints_temp(s),roads_temp(s),lanes_temp(s)) = ctr + 1;
                ctr = ctr + 1;
            end
        end
    end
    
%     if mod(t, delta_t*num_iter/10) == 0
%         fprintf('Time = %f\n', t);
%     end
    
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
    total_wait_time = total_wait_time + sum(vehicles(v).wait);
    total_weighted_wait_time = total_weighted_wait_time + sum(W(vehicles(v).wait));
end

figure
hold on
for z = 1:2 % num_int
    for i = 1:num_w
        plot(delta_t*(0:num_iter-1), weights(z,:,i))
    end
end
plot(switch_log1, zeros(length(switch_log1),1), '*')
if num_int == 2 
    plot(switch_log2, zeros(length(switch_log2),1), '*')
end
xlabel('Time (s)')
ylabel('Weight')
title('Road weights')
ax = gca;
set(ax,'FontName','Times')
set(ax,'FontSize',14)
% legend('NS1', 'EW1', 'NS2', 'EW2')
saveas(gcf, 'weight_plot', 'png')

figure
hold on
%for i = 1:num_int*num_lanes*num_roads
for int = 1:num_int
    for road = 1:num_roads
        for lane = 1:num_lanes
            len = size(queue_lengths,4);
            plot(delta_t*(0:len-1), reshape(queue_lengths(int,road,lane,:),1,len))
        end
    end
end
title('Length of Queues')
xlabel('Time (s)')
ylabel('Queue length (num veh)')
ax = gca;
set(ax,'FontName','Times')
set(ax,'FontSize',14)
saveas(gcf, 'queue_plot', 'png')

% TO DO LIST
% All the random stuff mentioned in the code already
% Program motion in intersection
% Make stops more accurate, have vehicles correct at slow speed, or just lock into destination when close
% When extending to multiple intersections, have vehicle(i).wait reset when entering a new intersection
% Initialize vehicle structs, make it a fixed size
% Make an option to run without graphics
% Make phase change trigger match LaTeX doc, use eta and check that W(1) > eta*W(2)