clear; clc; close all
hold on;

% Initialize parameters
delta_t = .1;
num_iter = 600;
num_intersections = 1;
wait_thresh = 0.1; % 0 means time is added once a vehicle is stopped, 1 means time is added after slowing from max
% h = 0.1; % coefficient in weighting function
policy = 'custom'; % 'cycle'
max_speed = 20; % speed limit of system
yellow_time = max_speed/4; % this is heuristic
phase_length = 30; % time of whole intersection cycle
min_time = 5; % minimum time spent in a phase
switch_threshold = 1; % 0 means wait time must be greater to switch, 1 means double
spawn_rate = .2; % average vehicles per second
spawn_type = 'poisson'; % 'poisson'
all_straight = true; % true if no turns exist
num_roads = 4; % number of roads
num_lanes = 3; % number of lanes
lane_width = 3.2;
lane_length = 150;
save_video = true;

if all_straight
    straight_list = 1:num_lanes;
    turn_radius = Inf*ones(num_lanes,1);
    turn_length = 2*num_lanes*lane_width*ones(num_lanes,1);
else
    straight_list = 2:num_lanes-1;
    turn_radius = [(lane_width/2) Inf (7*lane_width/2)];
    turn_length = [(pi/2)*(lane_width/2) 2*num_lanes*lane_width (pi/2)*(7*lane_width/2)];
end

inter = MakeIntersection(num_intersections, lane_width, lane_length, num_lanes, all_straight);
DrawIntersection(inter);
hold on

rng(1000)
[road,lane] = SpawnVehicles(spawn_rate, num_roads, num_lanes, 0, delta_t, spawn_type);
time_enter = 0;
% make and draw all Vehicles according to chosen roads and lanes
vehicle = struct;
vehicle = DrawAllVehicles(inter, vehicle, road, lane, time_enter, max_speed);
% This keeps track of last vehicle to spawn in each lane, to check for
% collisions
latest_spawn = zeros(num_roads, num_lanes);

% Play this mj2 file with VLC
% vid_obj = VideoWriter('movie.avi','Archival');
vid_obj = VideoWriter('movie','MPEG-4');
vid_obj.FrameRate = 1/delta_t;
open(vid_obj)

% These parameters solve the equations for psi = 2 and T = 10
% c = [.54 1.5 1.5 -.95];
% weight = @(t) c(1) * (t + c(2))^c(3) + c(4);
weight = @(t) .05 * t^2;

switch_time = Inf;
inter(1).green = [1 3];
previous_state = 1;
title_str = 'green light on vertical road';

W = zeros(num_iter,2);
j = 1;
tic
% Run simulation 
for t = delta_t*(1:num_iter)
    
    % Calculates weight in each lane
    if ~isempty(fieldnames(vehicle))
        for i = 1:length(vehicle)
            if (vehicle(i).time_enter ~= -1 && vehicle(i).time_leave == -1 && ismember(vehicle(i).lane,1:num_lanes))
                if mod(vehicle(i).road, 2) == 1
                    W(j,1) = W(j,1) + weight(vehicle(i).wait);
                else
                    W(j,2) = W(j,2) + weight(vehicle(i).wait);
                end
            end
        end
    end
    
    % Yellow light time needs to be function of max velocity! Not a
    % function of phase_length
    if strcmp(policy, 'cycle')
        if mod(t,phase_length) < phase_length/2 - yellow_time
            inter(1).green = [1 3];
            title_str = 'green light on vertical road';
        elseif mod(t,phase_length) < phase_length/2
            inter(1).green = [];
            title_str = 'yellow light on vertical road';
        elseif mod(t,phase_length) < phase_length - yellow_time
            inter(1).green = [2 4];
            title_str = 'green light on horizontal road';
        else
            inter(1).green = [];
            title_str = 'yellow light on horizontal road';
        end

    elseif strcmp(policy, 'custom') 
        if switch_time < yellow_time
            inter(1).green = [];
            if previous_state == 1
                title_str = 'yellow light on horizontal road';
            elseif previous_state == 2
                title_str = 'yellow light on vertical road';
            end
        elseif switch_time < yellow_time + min_time
            if previous_state == 1
                title_str = 'green light on vertical road';
                inter(1).green = [1 3];
            elseif previous_state == 2
                title_str = 'green light on horizontal road';
                inter(1).green = [2 4];
            end
        else  % if switching is an option
            if previous_state == 2 && (W(j,1) - W(j,2))/W(j,2) > switch_threshold
                switch_time = 0;
                inter(1).green = [1 3];
                previous_state = 1;
            elseif previous_state == 1 && (W(j,2) - W(j,1))/W(j,1) > switch_threshold
                switch_time = 0;
                inter(1).green = [2 4];
                previous_state = 2;
            end
        end
        
    end

    title([sprintf('t = %3.f, ',t) title_str])
    text_box = uicontrol('style','text');
    if strcmp(policy, 'custom')
        text_str = ['Custom Wait Time Policy     ';
            '  vertical weight = ', sprintf('%8.2f',W(j,1));
            'horizontal weight = ', sprintf('%8.2f',W(j,2))];
    elseif strcmp(policy, 'cycle')
        text_str = ['Fixed Cycle Policy          ';
            '  vertical weight = ', sprintf('%8.2f',W(j,1)); 
            'horizontal weight = ', sprintf('%8.2f',W(j,2))];
    else
        text_str = ['  vertical weight =   ', sprintf('%8.2f',W(j,1)); 
            'horizontal weight = ', sprintf('%8.2f',W(j,2))];
    end
    set(text_box,'String',text_str)
    set(text_box,'Units','characters')
    set(text_box,'Position', [6 6 50 5])
    
    % set(textBox,'Position',[200 200 100 50])
    
    % if vehicle is nonempty, run dynamics, update wait, and draw vehicle
    if ~isempty(fieldnames(vehicle))
        vehicle = RunDynamics(inter, vehicle, straight_list, turn_radius, turn_length, wait_thresh, yellow_time, t, delta_t);
        for i = 1:length(vehicle)
            if vehicle(i).velocity <= wait_thresh*vehicle(i).max_velocity
                vehicle(i).wait = vehicle(i).wait + delta_t;
            end
            if isfield(vehicle, 'figure')
                delete(vehicle(i).figure);
            end
            if (vehicle(i).time_leave == -1 && vehicle(i).time_enter ~= -1)
                vehicle(i).figure = DrawVehicle(vehicle(i));
            end
        end
    end
    
    if save_video
        % disp('Before frame save:')
        % toc
        pause(0.03)
        current_frame = getframe(gcf);
        writeVideo(vid_obj, current_frame);
        % disp('After frame save:')
        % toc
    end
    
    % Now spawn new vehicles
    [road,lane] = SpawnVehicles(spawn_rate, num_roads, num_lanes, t, delta_t, spawn_type);
    if isempty(fieldnames(vehicle(1))) 
        ctr = 0; % overwrites the empty vehicle
    else
        ctr = length(vehicle); % count number of cars already spawned
    end
    if ~isnan(road) % if spawned at least one
        for h = 1:length(road) % assign every car its road and lane
            % If the last vehicle to spawn in the lane is too close, dont
            % spawn
            if latest_spawn(road(h),lane(h)) == 0 || ...
              norm(vehicle(latest_spawn(road(h),lane(h))).position - ...
              vehicle(latest_spawn(road(h),lane(h))).starting_point, 2) > ...
              4*vehicle(latest_spawn(road(h),lane(h))).length
                [vehicle] = MakeVehicle(inter, vehicle, (ctr + 1), lane(h), road(h), t, max_speed);
                latest_spawn(road(h),lane(h)) = ctr + 1;
                ctr = ctr + 1;
            end
        end
    end
    % disp('After MakeVehicle')
    % toc

    switch_time = switch_time + delta_t;
    j = j + 1;
end

close(vid_obj);
close(gcf);

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

figure
plot(delta_t*(0:num_iter-1), W(:, 1), 'r--')
hold on
plot(delta_t*(0:num_iter-1), W(:, 2), 'b')
xlabel('Time (s)')
ylabel('Weight')
title('Road weights')
legend('NS','EW')
saveas(gcf, 'weight_plot', 'png')

% TO DO LIST
% All the random stuff mentioned in the code already
% Program motion in intersection
% Make stops more accurate, have vehicles correct at slow speed, or just lock into destination when close
% When extending to multiple intersections, have vehicle(i).wait reset when entering a new intersection
% Initialize vehicle structs, make it a fixed size
% Make an option to run without graphics
% Make phase change trigger match LaTeX doc, use eta and check that W(1) > eta*W(2)