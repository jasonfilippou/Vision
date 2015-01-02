function [ M ] = scale_matrix( M, dim )
%SCALE_MATRIX Scales matrix M such that the values along the given dimension lie
%   between 0 and 1. This function is useful for data scaling in Machine
%   Learning algorithms.
%   M: the input matrix
%   dim: The dimension along which to scale. Default 1 (along rows, so normalizes columns)

if nargin < 2 
    dim = 1;
end
minElsRepeated = repmat(min(M,[],dim),size(M,dim),1); % minimum feature values repeated |M(dim)| - many times
maxElsRepeated = repmat(max(M,[],1),size(M,dim),1); % maximum feature values repeated |M(dim)| - many times:
range = maxElsRepeated - minElsRepeated; % Range of feature values.
M = (M - minElsRepeated) ./ range;
end

