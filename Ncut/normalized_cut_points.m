function [ groups ] = normalized_cut_points( p, sigma )
%NORMALIZED_CUT_POINTS Runs normalized_cut_cont_points and then discretizes its
%result.
%   Inputs:
%       p: a 2 x n matrix containing 2-D points
%       sigma: The standard deviation used for smoothing distances.
%   Outputs:
%       groups: A binary ({1, -1}) 1 x N vector indicating the association of
%       each pixel (or point) with cluster A or cluster B respectively.

[x, ~] = normalized_cut_cont_points(p, sigma);
%mean(x), std(x)
groups = (x > 0.7535); % Simple static threshold. Possible optimization: Beam search to find the threshold that optimizes the NCut objective function.
end

