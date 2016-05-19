function[vehicle]=makeAllVehicles(inters, vehicle, road, lane, time, t, false)
if isnan(road) == 0
    for i = 1:length(road)
        [vehicle] = makeVehicle(inters,vehicle, i, lane(i), road(i), time, false);
        vehicle(i).figure = drawVehicle(vehicle(i), t);
    end
end
end