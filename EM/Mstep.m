function [ line1, line2] = Mstep(Data, w1, w2)
%M-STEP Perform the M-step of the E-m algorithm for fitting lines to 2D
%   points. This step estimates parameters for both lines given the weights of
%   the points, by solving two weighted linear least squares problems.
%   Inputs:
%       Data: A 2 x n matrix with the data points in columns.
%       w1: An n x 1 vector with the weights of the points with respect to
%             the first line.
%       w2: An n x 1 vector with the weights of the points with respect to
%             the second line.
%   Outputs:
%       line1: The estimated parameters (slope and intercept) for the first
%           line.
%       line2: The estimated parameters (slope and intercept) for the
%           second line.

% Prep matrices:
y = Data(2, :)'; % n x 1 column vector
X = [Data(1, :) ; ones(1, size(Data, 2))]'; % n x 2 matrix of x coordinates augmented with '1's.
W1 = diag(w1); % Put weights in the main diagonal of a diagonal matrix.
W2 = diag(w2); % Same.

% Solve weighted linear least squares for both weight matrices:
line1 = (X'*W1*X)\(X'*W1*y);
line2 = (X'*W2*X)\(X'*W2*y);
end

