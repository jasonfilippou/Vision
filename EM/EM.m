function [ line1, line2 ] = EM( Data, sigma, iter, interm_plots )
%EM Fits two lines to 2D data points using the EM algorithm.
%   Inputs: 
%       Data: A 2 x n matrix with 2D data points in its columns.
%       sigma: The standard deviation parameter used in the E-step.
%       iter: The #iterations to run EM with.
%       interm_plots: A boolean variable which, if set, tells the code to
%           make intermediate plots of fitted lines and membership vectors
%           per EM iteration. Useful only for visualization purposes.
%   Outputs:
%       line1: A 1 x 2 vector containing the estimated parameters (slope 
%               and intercept) of the first line.
%       line2: A 1 x 2 vector containing the estimated parameters (slope 
%               and intercept) of the second line.

% Sanity checking
if nargin < 2
    fprintf('Need to supply data and standard deviation.\n');
    line1 = []; line2 = [];
    return;
elseif nargin < 3
    iter = 5;   % Run for 5 iterations by default.
elseif nargin < 4
    interm_plots = true; % Plot intermediate results by default
end

% Randomly initialize initial parameters for lines:
line1 = rand(1, 2); line2 = rand(1, 2);
x = Data(1, :); y = Data(2, :);
if interm_plots 
    h = figure; plot(x, y, 'bx', 'MarkerSize', 5); hold on;
    plotLine(min(x), max(x), line1, 0.01, 'k-', 3);
    plotLine(min(x), max(x), line2, 0.01, 'k-', 3);
    title('Initial guesses for lines, before running EM.', 'FontSize', 15, 'Interpreter', 'Latex');
    hold off;
    print(h, 'figures/beforeEM.png', '-dpng');
end

% Sequentially run E and M-steps "iter"-many times.
for i = 1:iter
    [w1, w2] = Estep(Data, line1, line2, sigma);
    [line1, line2] = Mstep(Data, w1, w2);
    if interm_plots
        % Plot membership vectors, as requested...
        h = figure; plot(x(w1 >= w2), y(w1 >= w2), 'gx', 'MarkerSize', 5); hold on;
        plot(x(w1 < w2), y(w1 < w2), 'rx', 'MarkerSize', 5); 
        % Also plot lines...
        plotLine(min(x), max(x), line1, 0.01, 'g-', 3);
        plotLine(min(x), max(x), line2, 0.01, 'r-', 3);
        hold off;
        title(sprintf('Iteration %d', i), 'FontSize', 15, 'Interpreter', 'Latex');
        print(h, sprintf('figures/iter%d.png', i), '-dpng');
    end
end
end