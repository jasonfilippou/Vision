function dist = unary_cost( L, R, MAXD , INF_VAL)
%UNARY_COST Compute the data term for every pixel in the stereo matching
%problem.
%   Inputs:
%       L: The left image. Assumed to have been read in through imread().
%       R: The right image. Assumed to have been read in through imread().
%       MAXD: The maximum possible disparity to be considered.
%       INF_VAL: The value of infinity used for the unary MRF costs.
%   Outputs:
%       dist: an h x w x MAXD matrix. dist(i, j, d) = 
%               (a) (L(i, j) - R(i, j-d))^2, if j-d >=1, or 
%               (b)  INF_VAL, otherwise.


% (1) Sanity checking
assert(size(L, 1) == size(R, 1) && size(L, 2) == size(R, 2), 'Images are of different size');
assert(MAXD < size(L, 2), sprintf('Maximum disparity value of %d was too large.', MAXD));
%(2) Compute dist matrix.
h = size(L, 1); w = size(L, 2);
dist = ones(h, w, MAXD+1) .* INF_VAL;

for d=0:MAXD 
    dist(:,d+1:w,d+1) = (L(:, d+1:w) - R(:, 1:w-d)) .^2;
end
end

