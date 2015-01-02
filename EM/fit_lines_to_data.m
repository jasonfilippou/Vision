%%% Part 1.2: Finding lines that fit a set of data-points using EM. %%%
% Using the dataset and stdev suggested:
x=0:0.05:1; y=(abs(x-0.5) < 0.25).*(x+1)+(abs(x-0.5) >=0.25).*(-x);
sigma= sqrt(0.1);

[line1, line2] = EM([x;y], sigma, 5, true);
h = figure; plot(x, y, 'bx', 'MarkerSize', 5); hold on;
plotLine(min(x), max(x), line1, 0.01, 'k-', 3); 
plotLine(min(x), max(x), line2, 0.01, 'k-', 3); hold off;
title('Results on data from part 1.', 'FontSize', 15, 'Interpreter', 'Latex');
print(h, 'figures/EM_results_no_noise.png', '-dpng');

% Experimenting with Gaussian noise over the parameter y....

for i = 0.1:0.1:1
    y_n = y + i*randn(size(y));
    [line1, line2] = EM([x;y_n], sigma, 5, false);
    h = figure; plot(x, y_n, 'bx', 'MarkerSize', 5); hold on;
    plotLine(min(x), max(x), line1, 0.01, 'k-', 3); 
    plotLine(min(x), max(x), line2, 0.01, 'k-', 3); hold off;
    title(sprintf('Results on data with fraction \n %.1f of Gaussian noise.', i'), 'FontSize', 15, 'Interpreter', 'Latex');
    print(h, sprintf('figures/EM_results_noise_%d.png', i*10), '-dpng'); 
end