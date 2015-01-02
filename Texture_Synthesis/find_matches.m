function [ pixelList ] = find_matches( T, S, M, Threshold )
%FIND_MATCHES find the best matches of a template to the sample image, given
% a binary mask which contains the exact number of neighbors that have
% already been covered (approximation to pixel CDF). 
%   Inputs:
%       T: An odd-sized square template of pixels to match to the original
%           image.
%       S: A sample of the original image. This is the sample that we match the
%           template to.
%       M: A binary mask of the same size as T which tells us which neighbors
%           of the center pixel of T have been matched already.
%       Threshold: The threshold used by the algorithm to filter out "bad"
%           matches. Is typically equal to 0.1 (see Efros and Leung).
%   Outputs:
%       pixelList: an n x 2 array containing the coordinates of n pixels, where
%           every pixel has scored approximately optimally in the SSD measure.
%   

% Sanity checking first
if nargin < 4
    Threshold = 0.1;
end

if(size(T) ~= size(M))
    err = MException('argCheck:badArgs', 'Size mismatch between template and binary mask');
    throw(err);
end
if(mod(size(T, 1), 2) == 0 || size(T, 1) ~= size(T, 2))
    err = MException('argCheck:badArgs', 'T should be a square, odd-sized template');
    throw(err);
end

D = SSD(T, S, M); % The meat of the algorithm
% Find all x and y coordinates of pixels whose match exceeds the best match plus
% a multiplicative threshold
[I, J]= ind2sub([size(D, 1), size(D,2)], find(D <= min(D(:)) * (1 + Threshold))); 
pixelList = [I J];
end

