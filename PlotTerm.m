% test coordination term
clear;clc;close all

alpha = 1;
zeta = 20;
E = 1;
g = 40;
T = 50; % arrival time
yellow = 5;
tsys = linspace(0,70,1000);
z = -T + tsys + yellow;
B = zeros(100,1);
ind = 1;
for z_ = z
    B(ind) = alpha*E*max([0, min([(z_+zeta)/zeta,1,g/zeta,(-z_+g)/zeta])]);
    ind = ind + 1;
end
plot(z,B)
xlim([-30 50])
ylim([-1 2])
xlabel('z (seconds)')
ylabel('B')
title('Coordination term')
ax = gca;
set(ax,'FontName','Times')
set(ax,'FontSize',14)