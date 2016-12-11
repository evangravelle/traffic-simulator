% Written by Evan Gravelle and Julio Martinez
% 12/11/16

function R = Rotate2d(theta)
% Creates 2D Rotation matrix
R= [cos(theta) -sin(theta);sin(theta) cos(theta)];
end