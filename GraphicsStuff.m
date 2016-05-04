clear;
clc;
%FigHandle = figure('Position', [100, 100, 1000, 895]);
axis off
axis equal 
h = animatedline;
axis([-10,10,-10,10])
hold on;
whitebg([0 .5 .6])

%Intersection Parameters - EVAN what are these? More descriptive names if
%possible, also I have initialized some stuff in Initialize.m
a1 = 1.5; b1 = 10;
a2 = -10; b2 = -1.5;
center = [0,0];
left = [1.5, 1.5];
right = [-1.5, -1.5];
laneWidth = 0.5;

%12-OClock Lanes
road1Left =     plot(left,  [a1,b1]);
lane11Left =    plot(left - laneWidth,      [a1,b1], '--');
lane12Left =    plot(left - 2*laneWidth,  [a1,b1], '--');
centerDivide1 = plot(center,      [a1,b1]);
lane11Right =   plot(right + 2*laneWidth,[a1,b1], '--');
lane12Right =   plot(right + laneWidth,    [a1,b1], '--');
road1Right =    plot(right,[a1,b1]);
%3-OClock Lanes
road2Left =     plot([a2,b2], left);
lane21Left =    plot([a2,b2], left - laneWidth, '--');
lane22Left =    plot([a2,b2], left- 2*laneWidth, '--');
centerDivide2 = plot([a2,b2], center);
lane21Right =   plot([a2,b2], right + 2*laneWidth, '--');
lane22Right =   plot([a2,b2], right + laneWidth, '--');
road2Right =    plot([a2,b2], right);
%6-OClock Lanes
road3Left =     plot(left,  [b2,a2]);
lane31Left =    plot(left - laneWidth,      [b2,a2], '--');
lane32Left =    plot(left - 2*laneWidth,  [b2,a2], '--');
centerDivide3 = plot([0,0],      [b2,a2]);
lane31Right =   plot(right + 2*laneWidth,[b2,a2], '--');
lane32Right =   plot(right + laneWidth,    [b2,a2], '--');
road3Right =    plot(right,[b2,a2]);
%9-OClock Lanes
road4Left =     plot([a1,b1],   left);
lane41Left =    plot([a1,b1],   left - laneWidth, '--');
lane42Left =    plot([a1,b1],   left - 2*laneWidth, '--');
centerDivide4 = plot([a1,b1],   center);
lane41Right =   plot([a1,b1],   right + 2*laneWidth, '--');
lane42Right =   plot([a1,b1],   right + laneWidth, '--');
road4Right =    plot([a1,b1],   right);

%Set Thick boarders Outside on perimeter
road1Left.LineWidth = 2;
road2Left.LineWidth = 2;
road3Left.LineWidth = 2;
road4Left.LineWidth = 2;
road1Right.LineWidth = 2;
road2Right.LineWidth = 2;
road3Right.LineWidth = 2;
road4Right.LineWidth = 2;

%Specifiy Border Colors
road1Left.Color = 'k';
road2Left.Color = 'k';
road3Left.Color = 'k';
road4Left.Color = 'k';
road1Right.Color = 'k';
road2Right.Color = 'k';
road3Right.Color = 'k';
road4Right.Color = 'k';

%Specifiy Lane Dividing Colors
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

%Specify Center Divide Color
centerDivide1.Color = 'y';
centerDivide2.Color = 'y';
centerDivide3.Color = 'y';
centerDivide4.Color = 'y';

