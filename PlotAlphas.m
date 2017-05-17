% Plot alpha
% custom algorithm
% phi = .05, switch_thresh = 2, wait_threash = .1
% spawn_rate = .8 (main road is doubled)

alpha = [0, .01, .1, 1, 3, 10];
tt = [8.9, 9.15, 8.89, 8.41, 8.72, 9.43];
twt = [3.9, 3.84, 3.98, 3.94, 3.96, 4.61];
twwt = [4.72, 4.46, 4.86, 4.71, 4.81, 6.52];

figure
semilogx(alpha, tt)
hold on
semilogx(alpha, twt)
semilogx(alpha, twwt)
title('Performance Metrics')
xlabel('Coordination coefficient (alpha)')
ylabel('Time (seconds)')
legend('tt','twt','twwt')
ax = gca;
set(ax,'FontName','Times')
set(ax,'FontSize',14)