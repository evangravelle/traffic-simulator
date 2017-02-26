% test coordination term
clear;clc;close all

alpha = 1;
zeta = 5;
E = 10;
g = 10;
T = 50;
S = 5;
tsys = linspace(0,70,1000);
z = T - tsys - S;
B = zeros(100,1);
ind = 1;
for z_ = z
    B(ind) = alpha*E*max([0, min([z_/zeta+1,1,(g-z_)/zeta])]);
    ind = ind + 1;
end
plot(z,B)
ylim([-5 20])
xlabel('z (seconds)')
ylabel('B')
title('Coordination term')
ax = gca;
set(ax,'FontName','Times')
set(ax,'FontSize',14)