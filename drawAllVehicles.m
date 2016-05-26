function[vehicle]=drawAllVehicles(inters, vehicle, road, lane, time, t, false)
    
    %number of Vehicles in Que
    if isfield(vehicle, 'length') == false
        in_que = 0;
    else
        in_que = length(vehicle); 
    end
    
    % Draw all old vehicles and current time
    if in_que > 0;
        for i = 1:in_que
            vehicle(i).figure = drawVehicle(vehicle(i), t);
        end
    end
    
    % Now assign and draw new vehicles
    if isnan(road) == false
        % number of new Vehicles Spawned
        num_spawned = length(road);
        % make assignments and draw
        for j = 1:num_spawned
            [vehicle] = makeVehicle(inters,vehicle, (in_que + j), lane(j), road(j), time, false);
            vehicle(in_que+j).figure = drawVehicle(vehicle(in_que+j), t);
        end
    end
end