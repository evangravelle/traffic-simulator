function[f] = makeIntersection(center, laneWidth, interRange, i, phase)
%% If no input arguments are given
if nargin < 1
    interRange = 200; %Intersection Range
    x = 50; y = 100;
    laneWidth = 12; %width of each lane 
    i = 1;
end

%% rewrite center as (x,y)
x = center(1);
y = center(2);

%% Figure properties
f = figure(i); %places a handle on the figure
axis off %turns axis off
axis equal  %makes axis equal length in both x and y direction

%% Set axis range and background color
%axis([-interRange,interRange,-interRange,interRange])
hold on; %keep all plots on same figure
whitebg([0 .5 .6]) %background color

%% Lane Properties
laneRange = [3*laneWidth, interRange]; %Sets where lane Starts and Ends
centerRange = [0,0]; % Point at which center starts and ends before adding x and y

%% 12-OClock Lanes
road1Left =     plot(centerRange + 3*laneWidth + x,  laneRange + y);
lane11Left =    plot(centerRange + 2*laneWidth + x, laneRange + y, '--');
lane12Left =    plot(centerRange + 1*laneWidth + x, laneRange + y, '--');
centerDivide1 = plot(centerRange + x, laneRange + centerRange + y);
lane11Right =   plot(centerRange - 1*laneWidth + x, laneRange + y, '--');
lane12Right =   plot(centerRange - 2*laneWidth + x, laneRange + y, '--');
road1Right =    plot(centerRange - 3*laneWidth + x, laneRange + y);

%% 3-OClock Lanes
road2Left =     plot(laneRange + x, centerRange + 3*laneWidth + y);
lane21Left =    plot(laneRange + x, centerRange + 2*laneWidth + y, '--');
lane22Left =    plot(laneRange + x, centerRange + 1*laneWidth + y, '--');
centerDivide2 = plot(laneRange + x, centerRange + y);
lane21Right =   plot(laneRange + x, centerRange - 1*laneWidth + y, '--');
lane22Right =   plot(laneRange + x, centerRange - 2*laneWidth + y, '--');
road2Right =    plot(laneRange + x, centerRange - 3*laneWidth + y);

%% 6-OClock Lanes
road3Left =     plot(centerRange + 3*laneWidth + x,  -laneRange + y);
lane31Left =    plot(centerRange + 2*laneWidth + x, -laneRange + y, '--');
lane32Left =    plot(centerRange + 1*laneWidth + x, -laneRange + y, '--');
centerDivide3 = plot(centerRange + x, -laneRange + y);
lane31Right =   plot(centerRange - 1*laneWidth + x, -laneRange + y, '--');
lane32Right =   plot(centerRange - 2*laneWidth + x, -laneRange + y, '--');
road3Right =    plot(centerRange - 3*laneWidth + x, -laneRange + y);
%% 9-OClock Lanes
road4Left =     plot(-laneRange + centerRange + x,   centerRange + 3*laneWidth + y);
lane41Left =    plot(-laneRange + centerRange + x,   centerRange + 2*laneWidth + y, '--');
lane42Left =    plot(-laneRange + centerRange + x,   centerRange + 1*laneWidth + y, '--');
centerDivide4 = plot(-laneRange + centerRange + x,   centerRange + y);
lane41Right =   plot(-laneRange + centerRange + x,   centerRange - 1*laneWidth + y, '--');
lane42Right =   plot(-laneRange + centerRange + x,   centerRange - 2*laneWidth + y, '--');
road4Right =    plot(-laneRange + centerRange + x,   centerRange - 3*laneWidth + y);

%% Set Thick boarders Outside on perimeter
road1Left.LineWidth = 2;
road2Left.LineWidth = 2;
road3Left.LineWidth = 2;
road4Left.LineWidth = 2;
road1Right.LineWidth = 2;
road2Right.LineWidth = 2;
road3Right.LineWidth = 2;
road4Right.LineWidth = 2;

%% Colors
% Specifiy Border Colors
road1Left.Color = 'k';
road2Left.Color = 'k';
road3Left.Color = 'k';
road4Left.Color = 'k';
road1Right.Color = 'k';
road2Right.Color = 'k';
road3Right.Color = 'k';
road4Right.Color = 'k';

% Specify Lane Dividing Colors
lane11Left.Color = 'w';
lane12Left.Color = 'w';
lane11Right.Color = 'w';
lane12Right.Color = 'w';
lane21Left.Color = 'w';
lane22Left.Color = 'w';
lane21Right.Color = 'w';
lane22Right.Color = 'w';
lane31Left.Color = 'w';
lane32Left.Color = 'w';
lane31Right.Color = 'w';
lane32Right.Color = 'w';
lane41Left.Color = 'w';
lane42Left.Color = 'w';
lane41Right.Color = 'w';
lane42Right.Color = 'w';

% Specify Center Divider Color
centerDivide1.Color = 'y';
centerDivide2.Color = 'y';
centerDivide3.Color = 'y';
centerDivide4.Color = 'y';
hold on;

% Make Semi Circles for Turning at Intersection
R = 4*laneWidth;  %First make radius of semicircle

%phase 1 [1,5]
phase11_theta = linspace(0, pi/2, 7);
x_phase1 = R*cos(phase11_theta) + x - 3*laneWidth;
y_phase1 = R*sin(phase11_theta) + y - 3*laneWidth;

%phase 2 [1,6]
phase2_1_theta = linspace(0, pi/2, 7);
x_phase2 = R*cos(phase2_1_theta) + x - 3*laneWidth;
y_phase2 = R*sin(phase2_1_theta) + y - 3*laneWidth;

phase2_2_theta = linspace(pi, 3*pi/2, 7);
x_phase2_2 = R*cos(phase2_2_theta) + x + 3*laneWidth;
y_phase2_2 = R*sin(phase2_2_theta) + y + 3*laneWidth;

%phase 3 [2,5]
phase3_theta = linspace(pi/2, pi, 7);
x_phase3 = R*cos(phase3_theta) + x + 3*laneWidth;
y_phase3 = R*sin(phase3_theta) + y - 3*laneWidth;

%phase 4 
phase4_theta = linspace(pi/2, pi, 7);
x_phase4 = R*cos(phase4_theta) + x + 3*laneWidth;
y_phase4 = R*sin(phase4_theta) + y - 3*laneWidth;
    
phase4_2_theta = linspace(3*pi/2, 2*pi, 7);
x_phase4_2 = R*cos(phase4_2_theta) + x - 3*laneWidth;
y_phase4_2 = R*sin(phase4_2_theta) + y + 3*laneWidth;

% Conditional for phase printing/plotting
if isequal(phase, [1,5]) 
    plot(x_phase1,y_phase1, '--', 'Color', 'w');
elseif isequal(phase, [1,6])
    plot(x_phase2,y_phase2, '--', 'Color', 'w'); axis equal;
    plot(x_phase2_2,y_phase2_2, '--', 'Color', 'w'); axis equal;
elseif isequal(phase, [2,5])
    plot(x_phase3,y_phase3, '--', 'Color', 'w'); axis equal;
elseif isequal(phase, [2,6])
    plot(x_phase4,y_phase4, '--', 'Color', 'w'); axis equal; 
    plot(x_phase4_2,y_phase4_2, '--', 'Color', 'w'); axis equal; 
end
   
end

