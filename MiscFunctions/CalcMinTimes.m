function min_times = CalcMinTimes(new_phase, num_lanes, queue_lengths, int, ...
  w_ind, min_times, min_time, packets, yellow_time, t)

rd1 = ceil(new_phase(1)/2);
if mod(new_phase(1),2) == 1
    ln1 = num_lanes;
else
    ln1 = 1:num_lanes-1;
end
q1 = max(queue_lengths(int, rd1, ln1, w_ind));

if length(new_phase) == 2
    rd2 = ceil(new_phase(2)/2);
    if mod(new_phase(2),2) == 1
        ln2 = num_lanes;
    else
        ln2 = 1:num_lanes-1;
    end
    q2 = max(queue_lengths(int, rd2, ln2, w_ind));
else
    q2 = 0;
end

qp = 0;
for p = 1:size(packets,1)
    % z = -packets(p,3) + t + yellow_time + stop_time;
    old_int = packets(p,1);
    E = packets(p,2);
    arrival_time = packets(p,3);
    zeta = E*1.25;
    open_time = arrival_time - t - yellow_time - 2 + zeta;
    if old_int == 1
        new_int = 2;
        phase_tmp = [7,8];
    elseif old_int == 2
        new_int = 1;
        phase_tmp = [3,4];
    end
    if int == new_int && ~isempty(intersect(phase_tmp, new_phase))
        qp = max([qp, open_time]);
    end 
end
min_times(int) = min([3.5+1.50*max([q1,q2,qp]), min_time]);
end