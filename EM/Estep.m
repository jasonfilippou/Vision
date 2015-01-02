function [ w1, w2 ] = Estep( Data, line1, line2, sigma )
%ESTEP Perform the E-step of the EM algorithm for the problem of fitting
%2D lines to 2D points. The purpose of this step is to estimate the weights of
%the points in the data given the (known) parameters of the lines.
%   Inputs:
%       Data: A 2 x n matrix containing data points in its columns.
%       line1: A 2 x 1 vector containing the parameters of the first line
%           (slope and intercept).
%       line2: A 2 x 1 vector containing the parameters of the second line
%           (slope and intercept).
%       sigma: The standard deviation to use in the softmin function.
%   Outputs:
%       w1: A 1 x n vector containing the weights for every point with
%           respect to the first line.
%       w2: A 1 x n vector containing the weights for every point with
%           respect to the second line.

% Prep data:
a1 = line1(1); b1 = line1(2);
a2 = line2(1); b2 = line2(2);
y = Data(2, :)';
x = Data(1, :)';

% Compute residuals:
r1 = y - (a1 .* x + b1);
r2 = y - (a2 .* x + b2);

% Weights are soft-mins of residuals:
w1 = exp(-r1.^2 / (sigma .^2)) ./ (exp(-r1.^2 / (sigma .^2) )+ exp (-r2.^2 / (sigma .^2)));
w2 = exp(-r2.^2 / (sigma .^2)) ./ (exp(-r1.^2 / (sigma .^2)) + exp (-r2.^2 / (sigma .^2)));
end

