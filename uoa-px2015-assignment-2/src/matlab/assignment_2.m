initial_angles = [0.01:0.04:0.9, 0.9:0.001:0.999]; % The initial angles to be examined (as a factor of pi)
initial_angles = arrayfun(@(x) x*pi, initial_angles); % Muliply each of the elements by pi to obtain the initial angles to be used
g = 9.8; % gravity
l = 2; % length

len = length(initial_angles);
periods = [];

for i = 1:len

    % Run rk solve with the different initial angles
    [times, pos] = rksolve(make_pend(g, l), 0, 30, [initial_angles(i), 0], 0.01);

    % Find out the zeros with the zero crossing function. pos(2, :) selects
    % the second row of the data (i.e. theta)
    zeros = zerocrossing(times, pos(2, :));

    % Calculate the average distance between the zeros
    % This will give 0.5*period as the pendulum goes through zero
    % twice for every swing
    % 1. Add all the distances up
    len_zeros = length(zeros)-1;
    T = 0;
    for j = 1:(len_zeros)
        T = T + (zeros(j+1)-zeros(j));
    end

    % 2. Devide through the differences to get the average and
    % multiply by two to get the actual period
    T_numerical = (T / len_zeros) * 2;

    periods(i) = T_numerical;
end

f = figure();

plot(initial_angles, periods, 'LineWidth', 2);
hold on
plot(initial_angles, periods, 'o');
hold on

plot([initial_angles(1), initial_angles(len)], [periods(1), periods(1)], ':', 'LineWidth', 2)

axis([0, pi, 0, max(periods)*1.1])
lgd = legend('T', 'Sampling points', 'T_0');
lgd.Location = 'northwest';
title('Period vs. Initial Angle')
xlabel 'Initial angle (rad)';
ylabel 'Period (s)';

saveas(f, '../output/assignment2.png');
