function[road,lane] = poissonSpawn(lambda, max_num_vehicles, num_roads, num_lanes)
%Set average number of cars that appear at once
%lambda = 2;
%generate a random number
R = poissrnd(lambda);
%check if value is too large, if so change again
while R > max_num_vehicles;
    R = poissrnd(lambda);
end
k = 0;
%check to see if any cars are made
road = zeros(1,R);
lane = zeros(1,R);
if R > 0
    for i = 1:R
        %choose a road randomly
        road(i) = randi([1,num_roads]);
        %choose a lane randomly
        lane(i) = randi([1,num_lanes]);
        %check if lane is already taken
        if i > 1
            %first check if road has been selected
            disp('before if')
            if any(road(i) == road(1:end-1))
                %return the road number (key) if so
                key = find(road(i) == road(1:end-1));
                %use the road number to make sure we select a distinct lane
                disp('before while')
                while lane(i) == lane(key) || k < 10 %repeat if necessary
                    disp('in while')
                    lane(i) = randi([1,3]);
                    k = k + 1;
                end
            end
        end
    end
end
end


