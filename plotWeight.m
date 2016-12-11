% Written by Evan Gravelle and Julio Martinez
% 12/11/16

% Solve for weight parameters given 2 user parameters
clear;clc; close all
psi = 2;
T = 10;

t = linspace(0, 10, 100);
alpha = 1.5;
beta = 1.5;
phi = 1/(alpha * beta^(alpha - 1));
gamma = -phi * beta^alpha;
y = phi * (t + beta).^alpha + gamma;
alpha, beta, phi, gamma
plot(t,y)
axis equal
% beta = linspace(-10, 10, 100);
% func = ((T + beta).^(2 * (T + beta) + beta / (psi * T) - 1) ./ beta.^(2 * (T + beta) + beta / (psi * T) - 1)) - 2 * psi * T;
% plot(beta, func)
% 
% alpha = 2 * (T - beta) + beta / (psi * T);
% beta = T / (exp(log(2 * psi * T)/(alpha - 1)) - 1);
% phi = beta^(1 - alpha) / alpha;
% gamma = -phi * beta^alpha;
% 
% weight = @(t) phi * (t - beta)^alpha + gamma;
% ezplot(weight)