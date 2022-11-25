t_min = 5;
t_max = 10;
initial_t_in = 22;
t_out = make_Tout(t_min, t_max);
heating_off = make_heating(2, 0, t_out);
heating_on = make_heating(2, 25.5, t_out);



% Run rk solve with the different initial angles
[times, result_off] = rksolve(heating_off, 0, 20, initial_t_in, 0.01);
[times, result_on] = rksolve(heating_on, 0, 20, initial_t_in, 0.01);

len_time = length(times);

t_out_values = arrayfun(@(t)  t_out(0, t), times);

f = figure();

plot(times, result_off, 'LineWidth', 2);
hold on

plot(times, result_on, 'LineWidth', 2);
hold on

plot([0, 20], [t_min, t_min])
hold on

plot([0, 20], [t_max, t_max])
hold on

plot(times, t_out_values)

title('Temperature vs. Time')
legend('Heating off', 'Heating on', 'T_{min}', 'T_{max}', 'T_{out}')
xlabel 'Time (days)';
ylabel 'Temperature (C°)';

% This save the plot to the filesytem
saveas(f, '../output/assignment3.png');
