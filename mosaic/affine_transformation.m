function [ T ] = affine_transformation( A1, A2 )
%AFFINE_TRANSFORMATION Compute the affine transformation mapping matrix A1
% to matrix A2. 
%   Inputs:
%       A1: A 2x3 matrix containing 3 2D points in its columns
%       A2: A 2x3 matrix also containing 3 2D points in its columns.
%   Outputs:
%       T: A 2 x 3 matrix encoding the affine transformation connecting the
%       points in A1 and the points in A2. 
A1 = [A1; ones(1, size(A1, 2))]; % Homogeneous coordinates
T = A2 * pinv(A1); % Sometimes matrices are almost singular, so I really had to use pinv here to avoid warnings.
end

