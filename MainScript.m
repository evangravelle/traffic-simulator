% Written by Evan Gravelle
% 12/11/16
% clear; clc; close all
global alpha
clearvars -except alpha
clc; close all
addpath('MiscFunctions')

% Initialize parameters
policy = 'custom'; % the options are 'custom', 'cycle', or 'tapioca'
spawn_rate = 1.0; % average vehicles per second
alpha = 1; % coefficient on coordination term

delta_t = .1;
num_iter = 3000;
wait_thresh = 0.1; % number between 0 and 1, 0 means time is added once a vehicle is stopped, 1 means time is added after slowing from max
max_speed = 20; % speed limit of system
yellow_time = max_speed/4; % this is heuristic
stop_time = 5; % given by deltaV/minAccel
split = .44; % the percent of time spent in the LESS dense road
phase_length = 60; % time of whole intersection cycle
offset = 17.5; % the right intersection is ahead of the left one by this amount
min_time = 10; % minimum time spent in a phase
min_veh = 7;
switch_threshold = 1; % 0 means wait time must be greater to switch, 1 means double
spawn_type = 'poisson'; % 'poisson' or 'constant'
all_straight = false; % true if no turns exist
num_int = 2; % number of intersections
num_roads = 4; % number of roads
num_lanes = 3; % number of lanes
lane_width = 3.2; 
lane_length = 150; 
make_video = true;
make_textbox = true;
weight_type = 'quadratic'; % 'linear' or 'quadratic'
main_road = true; % if true, Poisson distributions are varied
make_plots = true;
write_file = false;

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
    % row = joint phase number, column = which phase is constant
    phases_compat_inds = [2 3;1 4;1 4;2 3;6 7;5 8;5 8;6 7]; 
    phases = [2 6;1 2;5 6;1 5;4 8;3 4;7 8;3 7];
    init_lights = 'grrrgrrr';
    if offset < mod(phase_length*split/2 - yellow_time, phase_length+eps)
        init_lights = [init_lights; 'grrrgrrr'];
    elseif offset < mod(phase_length*split/2, phase_length+eps)
        init_lights = [init_lights; 'yrrryrrr'];
    elseif offset < mod(phase_length*split - yellow_time, phase_length+eps)
        init_lights = [init_lights; 'rgrrrgrr'];
    elseif offset < mod(phase_length*split, phase_length+eps)
        init_lights = [init_lights; 'ryrrryrr'];
    elseif offset < mod(phase_length*(split + (1-split)/2) - yellow_time, phase_length+eps)
        init_lights = [init_lights; 'rrgrrrgr'];
    elseif offset < mod(phase_length*(split + (1-split)/2), phase_length+eps)
        init_lights = [init_lights; 'rryrrryr'];
    elseif offset < mod(phase_length - yellow_time, phase_length+eps)
        init_lights = [init_lights; 'rrrgrrrg'];
    else
        init_lights = [init_lights; 'rrryrrry'];
    end
end

ints = MakeIntersections(num_int, lane_width, lane_length, num_lanes, init_lights, all_straight);
DrawIntersections(ints);

rng(10)
[ints_temp,roads_temp,lanes_temp] = SpawnVehicles(spawn_rate, num_int, num_roads, num_lanes, 0, delta_t, spawn_type, main_road);
time_enter = 0;
% make and draw all Vehicles according to chosen roads and lanes
vehicles = struct;
vehicles = DrawAllVehicles(ints, vehicles, ints_temp, roads_temp, lanes_temp, time_enter, max_speed);
% This keeps track of last vehicle to spawn in each lane, to check for collisions
latest_spawn = zeros(num_int, num_roads, num_lanes);
queue_lengths = zeros(num_int, num_roads, num_lanes, num_iter+1);
packets = [];
max_accel = 1.8;
T = 22; % (int_dist-.5*max_speed^2/max_accel)/max_speed; % time for platoon to reach new intersection
min_times = min_time*ones(num_int,1);
eps = .001;

% Play this mj2 file with VLC
if make_video
    vid_name = [policy, '_', num2str(spawn_rate)];
    vid_obj = VideoWriter(vid_name);
    vid_obj.FrameRate = 1/delta_t;
    open(vid_obj)
end

% These parameters solve the equations for psi = 2 and T = 10
% c = [.54 1.5 1.5 -.95];
% W = @(t) c(1) * (t + c(2))^c(3) + c(4);
% W = @(t) .05 * (t^2 + t);
% Functions
if strcmp(weight_type, 'linear')
    W = @(t) t;
elseif strcmp(weight_type, 'quadratic')
    W = @(t) .05 * t.^2;
end
B = @(alp,E,z,zeta,g) alp*E*max([0, min([z/zeta+1,1,g/zeta,-z/zeta+g/zeta])]);

switch_time = Inf*ones(num_int,1);
hnd = [];
switch_log1 = [];
switch_log2 = [];
if all_straight
    num_w = 2;
else
    num_w = 8;
end
weights = zeros(num_int,num_iter,num_w);
added_weights = zeros(num_int,num_iter,num_w);
time_of_phase = zeros(num_int,num_w);
counts = zeros(num_int,num_w);
score = zeros(num_int,num_w);

tic_times = zeros(6,num_iter);
first = true;

w_ind = 1;
% Run simulation
for i = 1:num_iter
    t = delta_t * i;
    tic;
    % Calculate weights in each lane
    if ~isempty(fieldnames(vehicles))
        [weights(:,w_ind,:), added_weights(:,w_ind,:)] = CalcWeights(vehicles, ...
            num_int, num_w, num_lanes, wait_thresh, packets, t, yellow_time, stop_time, alpha, min_time, W, B);
    end
    if strcmp(policy, 'tapioca')
        if ~isempty(fieldnames(vehicles))
            counts = CalcCounts(vehicles, num_int, num_w, num_lanes);
        end
    end
    tic_times(1,i) = toc;
    tic;
    
    for k = 1:length(ints)
        
        if strcmp(policy, 'cycle')
            
            if all_straight
                if mod(t,phase_length) < phase_length/2 - yellow_time
                    if ~strcmp(ints(k).lights, 'grgr')
                        ints(k).lights = 'grgr';
                        hnd = DrawLights(ints, hnd);
                    end
                elseif mod(t,phase_length) < phase_length/2
                    if ~strcmp(ints(k).lights, 'yryr')
                        ints(k).lights = 'yryr';
                        hnd = DrawLights(ints, hnd);
                    end
                elseif mod(t,phase_length) < phase_length - yellow_time
                    if ~strcmp(ints(k).lights, 'rgrg')
                        ints(k).lights = 'rgrg';
                        hnd = DrawLights(ints, hnd);
                    end
                else
                    if ~strcmp(ints(k).lights, 'ygyg')
                        ints(k).lights = 'ygyg';
                        hnd = DrawLights(ints, hnd);
                    end
                end
            else
                if k == 2
                    if mod(t-offset,phase_length) < phase_length*split/2 - yellow_time
                        ints(k).lights = 'grrrgrrr';
                    elseif mod(t-offset,phase_length) < phase_length*split/2
                        ints(k).lights = 'yrrryrrr';
                    elseif mod(t-offset,phase_length) < phase_length*split - yellow_time
                        ints(k).lights = 'rgrrrgrr';
                    elseif mod(t-offset,phase_length) < phase_length*split
                        ints(k).lights = 'ryrrryrr';
                    elseif mod(t-offset,phase_length) < phase_length*(.5+split/2) - yellow_time
                        ints(k).lights = 'rrgrrrgr';
                    elseif mod(t-offset,phase_length) < phase_length*(.5+split/2)
                        ints(k).lights = 'rryrrryr';
                    elseif mod(t-offset,phase_length) < phase_length - yellow_time
                        ints(k).lights = 'rrrgrrrg';
                    else
                        ints(k).lights = 'rrryrrry';
                    end
                elseif k == 1
                    if mod(t,phase_length) < phase_length*split/2 - yellow_time
                        ints(k).lights = 'grrrgrrr';
                    elseif mod(t,phase_length) < phase_length*split/2
                        ints(k).lights = 'yrrryrrr';
                    elseif mod(t,phase_length) < phase_length*split - yellow_time
                        ints(k).lights = 'rgrrrgrr';
                    elseif mod(t,phase_length) < phase_length*split
                        ints(k).lights = 'ryrrryrr';
                    elseif mod(t,phase_length) < phase_length*(split + (1-split)/2) - yellow_time
                        ints(k).lights = 'rrgrrrgr';
                    elseif mod(t,phase_length) < phase_length*(split + (1-split)/2)
                        ints(k).lights = 'rryrrryr';
                    elseif mod(t,phase_length) < phase_length - yellow_time
                        ints(k).lights = 'rrrgrrrg';
                    else
                        ints(k).lights = 'rrryrrry';
                    end
                end
            end
            
        elseif strcmp(policy, 'custom')
            
            if all_straight
                
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
                
            else
                % if stuck in yellow
                if switch_time(k) < yellow_time
                    % do nothing
                % if stuck in green
                elseif switch_time(k) < yellow_time + min_times(k)
                    inds = strfind(ints(k).lights, 'y');
                    if ~isempty(inds)
                        ints(k).lights(inds) = 'r';
                        ints(k).lights(to_switch_to(k,:)) = 'g';
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
                        % fprintf('t = %f, int = %d, current_phase = [%d %d], new_phase = [%d %d]\n', t, k, ...
                        %   current_phase(1), current_phase(2), new_phase(1), new_phase(2))
                        % fprintf('max_phase_weight = %f, current_weight = %f\n', max_phase_weight, current_weight)
                        min_times = CalcMinTimes(new_phase, num_lanes, queue_lengths, k, ...
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
                        new_phase = setdiff(neighbor_phases(1,:),current_phase);
                        % fprintf('t = %f, int = %d, current_phase = %d, new_phase = %d\n', t, k, phases(current_phase,:), new_phase)
                        % fprintf('neighbor_phase_weight = %f, current_weight = %f\n', neighbor_weights(1), current_weight)
                        min_times = CalcMinTimes(new_phase, num_lanes, queue_lengths, k, ...
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
                        new_phase = setdiff(neighbor_phases(2,:),current_phase);
                        % fprintf('t = %f, int = %d, current_phase = %d, new_phase = %d\n', t, k, phases(current_phase,:), new_phase)
                        % fprintf('neighbor_phase_weight = %f, current_weight = %f\n', neighbor_weights(2), current_weight)
                        min_times = CalcMinTimes(new_phase, num_lanes, queue_lengths, k, ...
                            w_ind, min_times, min_time, packets, yellow_time, t);
                        to_switch_to(k,:) = new_phase;
                        switch_time(k) = 0;
                        if k == 1
                            switch_log1 = [switch_log1, t];
                        elseif k == 2
                            switch_log2 = [switch_log2, t];
                        end
                        ints(k).lights(setdiff(current_phase,neighbor_phases(2,:))) = 'y';
                    end
                end
            end
            
        elseif strcmp(policy, 'tapioca')
            
            active_phase_inds = [strfind(ints(k).lights, 'g'), strfind(ints(k).lights, 'y')];
            time_of_phase(k,active_phase_inds) = t;
            
            if all_straight
                % Not yet implemented
            else
                
                % if stuck in yellow
                if switch_time(k) < yellow_time
                    % do nothing
                % if stuck in green
                elseif switch_time(k) < yellow_time + min_times(k)
                    inds = strfind(ints(k).lights, 'y');
                    if ~isempty(inds)
                        ints(k).lights(inds) = 'r';
                        ints(k).lights(to_switch_to(k,:)) = 'g';
                    end
                % if switching is an option
                else
                    % Term 1, calculated at top of loop
                    
                    % Term 2
                    times = t - time_of_phase;
                    times(1,:) = times(1,:) / sum(times(1,:));
                    times(2,:) = times(2,:) / sum(times(2,:));
                    
                    LS = zeros(num_int,num_w);
                    norm_counts = zeros(num_int,num_w);
                    if sum(counts(1,:)) ~= 0
                        norm_counts(1,:) = counts(1,:) / sum(counts(1,:));
                    end
                    if sum(counts(2,:)) ~= 0
                        norm_counts(2,:) = counts(2,:) / sum(counts(2,:));
                    end
                    LS(1,:) = 1*norm_counts(1,:) + 1*times(1,:);
                    LS(2,:) = 1*norm_counts(2,:) + 1*times(2,:);
                    
                    % Term 3
                    out_counts = zeros(1,num_w);
                    if k == 2
                        out_counts(1,4) = sum(counts(1, [3 4]));
                        out_counts(1,5) = sum(counts(1, [3 4]));
                    elseif k == 1
                        out_counts(1,1) = sum(counts(2, [7 8]));
                        out_counts(1,8) = sum(counts(2, [7 8]));
                    end
                    GE = norm_counts(k,:) - out_counts;
                    
                    % Term 4
                    R = zeros(1,num_w);
                    if k == 2
                        D_score = [LS(1,6) + LS(1,7)
                            LS(1,1) + LS(1,8)
                            LS(1,2) + LS(1,3)
                            LS(1,4) + LS(1,5)];
                        [~, sorted_inds] = sort(D_score);
                        R([7 8]) = find(sorted_inds == 2) / 10;
                    elseif k == 1
                        D_score = [LS(2,6) + LS(2,7)
                            LS(2,1) + LS(2,8)
                            LS(2,2) + LS(2,3)
                            LS(2,4) + LS(2,5)];
                        [~, sorted_inds] = sort(D_score);
                        R([3 4]) = find(sorted_inds == 4) / 10;
                    end
                    score(k,:) = 1 * LS(k,:) + 1 * GE + 1 * R;
                    
                    phase_scores = zeros(num_w,1);
                    for tmp = 1:num_w
                        phase_scores(tmp) = sum(score(k,phases(tmp,:)));
                    end
                    
                    [max_score, max_ind] = max(phase_scores);
                    new_phase = phases(max_ind,:);
                    
                    inds = strfind(ints(k).lights, 'g');
                    [~, current_phase_ind] = ismember(inds, phases, 'rows');
                    current_phase = phases(current_phase_ind, :);
                    
                    min_times = CalcMinTimes(max_ind, num_lanes, queue_lengths, k, ...
                      w_ind, min_times, min_time, [], yellow_time, t);
                    
                    if ~ismember(current_phase(1), new_phase)
                        ints(k).lights(current_phase(1)) = 'y';
                    end
                    if ~ismember(current_phase(2), new_phase)
                        ints(k).lights(current_phase(2)) = 'y';
                    end
                        
                    to_switch_to(k,:) = new_phase;
                    switch_time(k) = 0;
                    if k == 1
                        switch_log1 = [switch_log1, t];
                    elseif k == 2
                        switch_log2 = [switch_log2, t];
                    end
                end
            end 
        end
        
        % if switching to enable flow toward another intersection, create packet
        % packet contains source intersection, number of vehicles, and time of arrival
        if strcmp(policy, 'custom')
            if k == 1 && abs(switch_time(k)-yellow_time) <= .001 && ismember(1, to_switch_to(k,:)) && queue_lengths(k,1,3,w_ind) > 0
                packets = [packets; k, min([min_veh,queue_lengths(k,1,3,w_ind)]), t + T];
            elseif k == 1 && abs(switch_time(k)-yellow_time) <= .001 && ismember(6, to_switch_to(k,:)) && sum(queue_lengths(k,3,1,w_ind)) > 0
                packets = [packets; k, min([min_veh,sum(queue_lengths(k,3,1,w_ind))]), t + T];
            elseif k == 1 && abs(switch_time(k)-yellow_time) <= .001 && ismember(8, to_switch_to(k,:)) && sum(queue_lengths(k,4,2,w_ind)) > 0
                packets = [packets; k, min([min_veh,sum(queue_lengths(k,4,2,w_ind))]), t + T];
            end
            if k == 2 && abs(switch_time(k)-yellow_time) <= .001 && ismember(2,to_switch_to(k,:)) && sum(queue_lengths(k,1,1,w_ind)) > 0
                packets = [packets; k, min([min_veh,sum(queue_lengths(k,1,1,w_ind))]), t + T];
            elseif k == 2 && abs(switch_time(k)-yellow_time) <= .001 && ismember(4,to_switch_to(k,:)) && sum(queue_lengths(k,2,2,w_ind)) > 0
                packets = [packets; k, min([min_veh,sum(queue_lengths(k,2,2,w_ind))]), t + T];
            elseif k == 2 && abs(switch_time(k)-yellow_time) <= .001 && ismember(5,to_switch_to(k,:)) && queue_lengths(k,3,3,w_ind) > 0
                packets = [packets; k, min([min_veh,queue_lengths(k,3,3,w_ind)]), t + T];
            end
        elseif strcmp(policy, 'tapioca')
            packets = [];
        end
    end
    tic_times(2,i) = toc;
    tic;
    
    if mod(t, 1) == 0
        % fprintf('Int1 = %s\n', ints(1).lights)
        % fprintf('Int2 = %s\n', ints(2).lights)
    end
    
    title_str = sprintf('Time = %.2f', t);
    title(title_str)
    
    % Right now, the textboxes don't get deleted, a new one gets put on top
    if make_textbox
        if first
            text_box = uicontrol('style','text');
            set(text_box,'Units','characters')
            if num_int == 1
                set(text_box,'Position', [25 15 40 6])
            else
                set(text_box,'Position', [48 15 40 6])
            end
            set(text_box, 'FontSize', 7)
            first = false;
        end
        if strcmp(policy, 'custom')
            text_str = ['Custom Policy       ', ints(1).lights, '                   ', ints(2).lights, '      '];
        elseif strcmp(policy, 'cycle')
            text_str = ['Cycle Policy        ', ints(1).lights, '                   ', ints(2).lights, '      '];
        elseif strcmp(policy, 'tapioca')
            text_str = ['TAPIOCA Policy      ', ints(1).lights, '                   ', ints(2).lights, '      '];
        end
        if all_straight
            text_str = [text_str;
                '  vertical weight1 = ', sprintf('%8.2f',weights(1,w_ind,1));
                'horizontal weight1 = ', sprintf('%8.2f',weights(1,w_ind,2))];
            if length(ints) == 2
                text_str = [text_str;
                    '  vertical weight2 = ', sprintf('%8.2f',weights(2,w_ind,1));
                    'horizontal weight2 = ', sprintf('%8.2f',weights(2,w_ind,2))];
            end
        else
            if strcmp(policy, 'tapioca')
                text_str = [text_str; 'Int1=', sprintf('%7.1f',score(1,:))];
                if length(ints) == 2
                    text_str = [text_str; 'Int2=', sprintf('%7.1f',score(2,:))];
                end
            else
                text_str = [text_str; 'Int1=', sprintf('%7.1f',weights(1,w_ind,:)+added_weights(1,w_ind,:))];
                if length(ints) == 2
                    text_str = [text_str; 'Int2=', sprintf('%7.1f',weights(2,w_ind,:)+added_weights(2,w_ind,:))];
                end
            end
        set(text_box,'String',text_str)
        end
    end
    tic_times(3,i) = toc;
    tic;
    
    % if vehicle is nonempty, run dynamics, update wait, and draw vehicle
    if ~isempty(fieldnames(vehicles))
        vehicles = RunDynamics(ints, vehicles, straight_list, turn_radius, turn_length, wait_thresh, t, delta_t);
        for v = 1:length(vehicles)
            if (vehicles(v).lane <= num_lanes)
                if strcmp(policy, 'tapioca')
                    queue_lengths(vehicles(v).int, vehicles(v).road, abs(vehicles(v).lane), w_ind+1) = ...
                        queue_lengths(vehicles(v).int, vehicles(v).road, abs(vehicles(v).lane), w_ind+1) + 1;
                elseif vehicles(v).velocity <= wait_thresh*vehicles(v).max_velocity
                    queue_lengths(vehicles(v).int, vehicles(v).road, abs(vehicles(v).lane), w_ind+1) = ...
                        queue_lengths(vehicles(v).int, vehicles(v).road, abs(vehicles(v).lane), w_ind+1) + 1;
                end
            end
            if isfield(vehicles, 'figure')
                delete(vehicles(v).figure);
            end
            if (vehicles(v).time_leave == -1 && vehicles(v).time_enter ~= -1)
                vehicles(v).figure = DrawVehicle(vehicles(v));
            end
        end
    end
    tic_times(4,i) = toc;
    tic;
    
    if make_video
        pause(0.03)
        current_frame = getframe(gcf);
        writeVideo(vid_obj, current_frame);
    end
    tic_times(5,i) = toc;
    tic;
    
    % Now spawn new vehicles
    [ints_temp,roads_temp,lanes_temp] = SpawnVehicles(spawn_rate, num_int, num_roads, num_lanes, t, delta_t, spawn_type, main_road);
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
    tic_times(6,i) = toc;
    
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
    if vehicles(v).time_leave > 0
        total_time = total_time + vehicles(v).time_leave - vehicles(v).time_enter;
    else
        total_time = total_time + t - vehicles(v).time_enter;
    end
    total_wait_time = total_wait_time + sum(vehicles(v).wait);
    total_weighted_wait_time = total_weighted_wait_time + sum(W(vehicles(v).wait));
end

if write_file
    % fid = fopen('alphas.txt', 'a');
    % fprintf(fid, '%f %f %f %f\n', alpha, total_time, total_wait_time, total_weighted_wait_time);
    % fclose(fid);
    
    fid = fopen('times.txt', 'a');
    fprintf(fid, '%f %f %f\n', total_time, total_wait_time, total_weighted_wait_time);
    fclose(fid);
end

if make_plots
    y_label = 'Weighted wait-time (sec*sec)';
    figure
    hold on
    for z = 1:num_int
        for i = 1:num_w
            plot(delta_t*(0:num_iter-1), weights(z,:,i))
        end
    end
    plot(switch_log1, zeros(length(switch_log1),1), '*')
    if num_int == 2
        plot(switch_log2, zeros(length(switch_log2),1), '*')
    end
    xlabel('Time (s)')
    ylabel(y_label)
    title('Cost of each phase')
    ax = gca;
    set(ax,'FontName','Times')
    set(ax,'FontSize',14)
%     saveas(gcf, 'weight_plot_custom_alpha40_spawn15_mainrd', 'png')
%     saveas(gcf, 'weight_plot_custom_alpha40_spawn15_mainrd', 'fig')
    
    figure
    hold on
    %for i = 1:num_int*num_lanes*num_roads
    % for int = 1:num_int
    %     for road = 1:num_roads
    %         for lane = 1:num_lanes
    %             len = size(queue_lengths,4);
    %             plot(delta_t*(0:len-1), reshape(queue_lengths(int,road,lane,:),1,len))
    %         end
    %     end
    % end
    len = size(queue_lengths,4);
    Q_max = zeros(len,1);
    for t = 1:len
        tmp = queue_lengths(:,:,:,t);
        Q_max(t) = max(tmp(:));
    end
    plot(delta_t*(0:len-1), Q_max)
    title('Length of Queues')
    xlabel('Time (s)')
    ylabel('Queue length (veh)')
    ax = gca;
    set(ax,'FontName','Times')
    set(ax,'FontSize',14)
    % saveas(gcf, 'queue_plot', 'fig')
    % saveas(gcf, 'queue_plot', 'png')
    
    figure
    plot(tic_times')
    xlabel('Iteration number')
    ylabel('Process Time')
    legend('weights', 'policy', 'textbox', 'dynamics', 'video', 'spawns')
end

% TO DO LIST
% All the random stuff mentioned in the code already
% Program motion in intersection
% Make stops more accurate, have vehicles correct at slow speed, or just lock into destination when close
% When extending to multiple intersections, have vehicle(i).wait reset when entering a new intersection
% Initialize vehicle structs, make it a fixed size
% Make an option to run without graphics
% Make phase change trigger match LaTeX doc, use eta and check that W(1) > eta*W(2)