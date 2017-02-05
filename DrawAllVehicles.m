% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function vehicles = DrawAllVehicles(ints, vehicles, ints_temp, roads_temp, lanes_temp, time, max_speed)
    
    %number of Vehicles in Queue
    if ~isfield(vehicles, 'length')
        in_queue = 0;
    else
        in_queue = length(vehicles); 
    end
    
    % Draw all old vehicles and current time
    if in_queue > 0
        for i = 1:in_queue
            vehicles(i).figure = DrawVehicle(vehicles(i));
        end
    end
    
    % Now assign and draw new vehicles
    if isnan(road) == false
        % number of new Vehicles Spawned
        num_spawned = length(road);
        % make assignments and draw

        for j = 1:num_spawned
            [vehicles] = MakeVehicle(ints, vehicles, in_queue + j, ints_temp(j), roads_temp(j), lanes_temp(j), time, max_speed);
            vehicles(in_queue+j).figure = DrawVehicle(vehicles(in_queue+j));
        end
    end
end