clear;clc;close all

c = .01;
x = linspace(1,50,100);
y = exp(c*x.^2);
z = 2*exp(c*(x-1).^2);

hold on
plot(x,y)
plot(x,z,'--')