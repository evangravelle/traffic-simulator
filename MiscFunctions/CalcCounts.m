function counts = CalcCounts(vehicles, num_int, num_w, num_lanes)

counts = zeros(num_int, 1, num_w);
for v = 1:length(vehicles)
    if (vehicles(v).time_enter ~= -1 && vehicles(v).time_leave == -1 && ismember(vehicles(v).lane,1:num_lanes))
        if num_w == 2
            if mod(vehicles(v).road, 2) == 1
                counts(vehicles(v).int,1,1) = counts(vehicles(v).int,1,1) + 1;
            else
                counts(vehicles(v).int,1,2) = counts(vehicles(v).int,1,2) + 1;
            end
        elseif num_w == 8
            phase = 2*vehicles(v).road - 1;
            if vehicles(v).lane == num_lanes
                counts(vehicles(v).int,1,phase) = counts(vehicles(v).int,1,phase) + 1;
            else
                counts(vehicles(v).int,1,phase+1) = counts(vehicles(v).int,1,phase+1) + 1;
            end
            
        end
    end
end