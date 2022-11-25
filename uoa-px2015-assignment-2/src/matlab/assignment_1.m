% Task 1

% Define a method calulating the pendiulum's period with the small
% angle approximation
small_angle_apprx = @(g, l) (2*pi*sqrt(l/g));

% Define the constants to be used
initial_angles = [0.2, 1.0, 2.0, 3.0, 3.14]; % The list of intial angles to be examined
g = 9.8; % gravity
l = 2; % length

% The number of initial angles to be examinend
len = length(initial_angles);

% Define a result matrix with one row for each value and one column for each
% intital angle plus one for the titles
comparison_result = cell(len+1, 4);

% Set the title for the output data
comparison_result{1, 1} = "Initial angle (rad)";
comparison_result{1, 2} = "Period (numerical solution)";
comparison_result{1, 3} = "Period (analytical solution)";
comparison_result{1, 4} = "Error";

% Iterate over all initial angles and examine how the pendulum behaves over time
for i = 1:len

    % Run rk solve with the different initial angles
    [times, pos] = rksolve(make_pend(g, l), 0, 30, [initial_angles(i), 0], 0.01);

    % Create a new figure for each run
    f = figure(i);

    f.Name = sprintf('Initial angle: %f rad', [initial_angles(i)]);

    angles = pos(1, :); % Select the first row of the data containg all angles
    velocities = pos(2, :); % Select the second row of the data containing all agular velocities

    % Plot the angle
    subplot(2, 1, 1)
    plot(times, angles, 'LineWidth', 2);
    axis([0, 30, min(angles)*1.5, max(angles)*1.5])
    title(sprintf('The angle of a pendulum with initial angle %.2f rad over time', initial_angles(i)))
    xlabel 'Time (s)';
    ylabel 'Angle (rad)';

    % Plot the velocity
    subplot(2, 1, 2) 
    plot(times, velocities, 'LineWidth', 2);
    axis([0, 30, min(velocities)*1.5, max(velocities)*1.5])
    title(sprintf('The velocity of a pendulum with initial angle %.2f rad over time', initial_angles(i)))
    xlabel 'Time (s)';
    ylabel 'Velocity (rad/s)';

    % Save the plot to hte file system for later use
    saveas(f, sprintf('../output/assignment1/%.2f_rad.png', [initial_angles(i)]));

    % Find out the zeros with the zero crossing function using
    % the angles
    calc_zeros = zerocrossing(times, angles);

    % Calculate the average distance between the zeros
    % This will give 0.5*period as the pendulum goes through zero
    % twice for every swing
    % 1. Add all the distances up
    len_zeros = length(calc_zeros)-1;
    T = 0;
    for j = 1:(len_zeros)
        T = T + (calc_zeros(j+1)-calc_zeros(j));
    end

    % 2. Devide through the differences to get the average and
    % multiply by two to get the actual period
    T_numerical = (T / len_zeros) * 2;
    T_apprx = small_angle_apprx(g, l);
    error = abs(T_numerical - T_apprx);
    
    % Assign the result column and limit each number to two
    % significant digits
    comparison_result{i+1, 1} = sprintf('%.2f', initial_angles(i));
    comparison_result{i+1, 2} = sprintf('%.2f', T_numerical);
    comparison_result{i+1, 3} = sprintf('%.2f', T_apprx);
    comparison_result{i+1, 4} = sprintf('%.2f', error);
end

% Write the result to the file system as a .csv file
writecell(comparison_result,'../output/assignment1/comparison_table.csv');