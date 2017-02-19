function new_weights = CalcWeights(vehicles, num_int, num_w, num_lanes, W)

new_weights = zeros(num_int, 1, num_w);
for v = 1:length(vehicles)
    if (vehicles(v).time_enter ~= -1 && vehicles(v).time_leave == -1 && ismember(vehicles(v).lane,1:num_lanes))
        if num_w == 2
            if mod(vehicles(v).road, 2) == 1
                new_weights(vehicles(v).int,1,1) = new_weights(vehicles(v).int,1,1) + W(vehicles(v).wait);
            else
                new_weights(vehicles(v).int,1,2) = new_weights(vehicles(v).int,1,2) + W(vehicles(v).wait);
                
            end
        elseif num_w == 8
            if vehicles(v).road == 1
                if vehicles(v).lane == num_lanes
                    new_weights(vehicles(v).int,1,1) = new_weights(vehicles(v).int,1,1) + W(vehicles(v).wait);
                else
                    new_weights(vehicles(v).int,1,2) = new_weights(vehicles(v).int,1,2) + W(vehicles(v).wait);
                end
            elseif vehicles(v).road == 2
                if vehicles(v).lane == num_lanes
                    new_weights(vehicles(v).int,1,3) = new_weights(vehicles(v).int,1,3) + W(vehicles(v).wait);
                else
                    new_weights(vehicles(v).int,1,4) = new_weights(vehicles(v).int,1,4) + W(vehicles(v).wait);
                end
            elseif vehicles(v).road == 3
                if vehicles(v).lane == num_lanes
                    new_weights(vehicles(v).int,1,5) = new_weights(vehicles(v).int,1,5) + W(vehicles(v).wait);
                else
                    new_weights(vehicles(v).int,1,6) = new_weights(vehicles(v).int,1,6) + W(vehicles(v).wait);
                end
            elseif vehicles(v).road == 4
                if vehicles(v).lane == num_lanes
                    new_weights(vehicles(v).int,1,7) = new_weights(vehicles(v).int,1,7) + W(vehicles(v).wait);
                else
                    new_weights(vehicles(v).int,1,8) = new_weights(vehicles(v).int,1,8) + W(vehicles(v).wait);
                end
            end
        end
    end
end

end