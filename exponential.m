% exponentials
clear;clc;close all

hold on
x = linspace(0,10,100);
f1 = x;
f2 = exp(.3045*x) - 1;
plot(x,f1,x,f2)

figure(2)
x1 = linspace(5,100,100);
y = x1.*exp(10./x1)-21;
plot(x1,y)