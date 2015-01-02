function [ line ] = fit_line( data )
%FIT_LINE Given a matrix of 2D data points, fits a line to the datapoints.
%   Inputs:
%       data: A 2 x n matrix with n 2D data points in the columns.
%   Outputs:
%       line: A 2 x 1 vector. line(1) is the slope of the fitted line 
%       (parameter 'a'), and line(2) is its intercept (parameter 'b').

% This problem is an application of linear regression, which has a nice closed-form
% solution. We need to be careful when forming our matrices, though, since
% 'data' contains both the x and y coordinates of our points.
y = data(2, :)'; % n x 1 column vector
X = [data(1, :) ; ones(1, size(data, 2))]'; % n x 2 matrix of x coordinates augmented with '1's.

% Closed-form solution:
line = (X'*X)\(X'*y);
end

