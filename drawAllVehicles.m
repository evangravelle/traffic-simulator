function[vehicle]=drawAllVehicles(inters, vehicle, road, lane, time)
    
    %number of Vehicles in Queue
    if ~isfield(vehicle, 'length')
        in_queue = 0;
    else
        in_queue = length(vehicle); 
    end
    
    % Draw all old vehicles and current time
    if in_queue > 0;
        for i = 1:in_queue
            vehicle(i).figure = drawVehicle(vehicle(i));
        end
    end
    
    % Now assign and draw new vehicles
    if isnan(road) == false
        % number of new Vehicles Spawned
        num_spawned = length(road);
        % make assignments and draw

        for j = 1:num_spawned
            [vehicle] = makeVehicle(inters,vehicle, (in_queue + j), lane(j), road(j), time);
            vehicle(in_queue+j).figure = drawVehicle(vehicle(in_queue+j));
        end
    end
end