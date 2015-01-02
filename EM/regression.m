%%% Part 1.1: Fitting lines to data %%%%
% First input
x=0:0.05:1; y=2*x+1;
line = fit_line([x;y]); a =line(1); b = line(2);
x_ex = -0.1:0.001:1.1; y_ex = a * x_ex + b; % Generate some points to plot the line
figure; plot(x, y, 'bx', 'MarkerSize', 5);
hold on; plot(x_ex, y_ex, 'r-', 'MarkerSize', 3); hold off;
title('Fit of line for first input.', 'FontSize', 15, 'Interpreter', 'Latex');

% Second input
x=0:0.05:1; y=2*x+1+0.1*randn(size(x));
line = fit_line([x;y]); a =line(1); b = line(2);
x_ex = -0.1:0.001:1.1; y_ex = a * x_ex + b; 
figure; plot(x, y, 'bx', 'MarkerSize', 5);
hold on; plot(x_ex, y_ex, 'r-', 'MarkerSize', 3); hold off;
title('Fit of line for second input.', 'FontSize', 15, 'Interpreter', 'Latex');

% Third input
x=0:0.05:1; y=(abs(x-0.5) < 0.25).*(x+1)+(abs(x-0.5) >=0.25).*(-x);
line = fit_line([x;y]); a =line(1); b = line(2);
x_ex = -0.1:0.001:1.1; y_ex = a * x_ex + b; % Generate some points to plot the line
figure; plot(x, y, 'bx', 'MarkerSize', 5);
hold on; plot(x_ex, y_ex, 'r-', 'MarkerSize', 3); hold off;
title('Fit of line for third input.', 'FontSize', 15, 'Interpreter', 'Latex');