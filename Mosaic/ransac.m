function [ Aopt ] = ransac( M )
%RANSAC Runs RANSAC to find the optimal transformation that maps the 1st
%and 2nd columns of M onto the 3rd and 4th columns of M. Inliers (points
%that are considered to be spatially close) are points which have a
%Euclidean distance under 2 from their matched points after applying the
%affine transformation which RANSAC found.
% 
%   Inputs:
%       M: An n x 4 matrix which contains the matched points in its rows.
%   Outputs:
%       Aopt: A 2 x 3 matrix, describing the best-scoring (*opt*imal) 
%       affine transformation, calculated as the transformation which induces 
%       the minimum Euclidean distance between matched points (in the feature 
%       space) after applying the relevant transformation.

P1 = M(:, 1:2);
P2 = M(:, 3:4);
C = cell(100, 2);
for iter = 1:1000   
    % Find the transformation that maps three random points from P2 onto their
    % matches to P1. Note that the input matrix M has already matched the
    % points for us (the matching for RANSAC is typically done by
    % correlating SIFT features).
    ind = randperm(size(M, 1), 3); % 3 random points
    A = affine_transformation(P2(ind, :)', P1(ind, :)'); 
    
    % Apply A to all the points in P2. P2 is n x 2 and A is 2 x 3. So we
    % first make P2 3 x n, then multiply A by that expansion to retrieve a
    % 2 x n result. We then transpose the result to get an n x 2 matrix
    % P2_tr. This matrix is the result of applying the transformation to
    % every point in P2.
    P2_tr = (A * [P2, ones(size(P2, 1), 1)]')'; 
    
    % Now, calculate the Euclidean distance between every row of P2_tr and
    % every row in P1. Store the result in an n x 1 matrix called ED.
    ED = sqrt(sum((P2_tr - P1).^2, 2));
    
    C{iter, 1} = length(ED(ED < 2)); % Store the score of the transformation (amount of mapped points spatially close enough to their SIFT-associated points)
    C{iter, 2} = A; % Store the transformation itself
end
C = sortrows(C, 1); % sort C according to first column. Note that this sorts in ascending order, but we want the transformation that matches the *most* points.
Aopt = C{end, 2};
end

