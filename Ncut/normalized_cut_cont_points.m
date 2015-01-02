function [ x, W ] = normalized_cut_cont_points( p, sigma )
%NORMALIZED_CUT_CONT_POINTS Runs the core of the normalized cut algorithm.
%   Inputs:
%       p: a 2 x n matrix containing 2-D points
%       sigma: The standard deviation used for smoothing distances.
%   Outputs:
%       x: An 1 x n continuous vector with values between -1 and 1. x(i)
%       represents our belief about how much pixel (or point) i should belong
%       to cluster A or cluster B.
%       W: The affinity matrix computed by the normalized cut algorithm.
%       Returned because callers might need it.

% A possible optimization for this function is to see whether inv(D) is 
% overkill for simply taking the inverse of a diagonal matrix. I'm not sure 
% whether MATLAB can detect the state of such a matrix and optimize inv.

% David suggested making W sparse, and we will do so. 
W = sparse(exp(-squareform(pdist(p')) / (sigma.^2)));
d = W * ones(size(W, 2), 1); % Sum up the rows of W...
D = diag(d); % and place the elements in the main diagonal of a diagonal matrix D.
M = sqrt(inv(D)) * (D - W) * sqrt(inv(D)); % The matrix M in the numerator of the Rayleigh Quotient.
fprintf('Computing eigenvectors of M...\n');
[V, ~] = eig(M);  % Solving the eigenvalue problem.
fprintf('Computed eigenvectors of M.\n');
z = V(:,2); % Eigenvector corresponding to second smallest eigenvalue.
y = sqrt(inv(D))*z; % Going back to y from z.
b = sum(d(y > 0)) / sum(d(y < 0)); % Ratio of associations.
x = (y - 1 + b) / (1 + b);  % Going back to x from y.
fprintf('Computed x.\n');
end

