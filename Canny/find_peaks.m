function [ M ] = find_peaks( I, sigma, thresh )
%FIND_PEAKS Non-Maximum Suppression to find pixels where the gradient 
% magnitude is locally maximum. The comparison is done against the
% neighbors of the pixels along the direction of the gradient vector.
%
%   Inputs:
%       I: The input image, assumed to be a double matrix read in through imread().
%       sigma: The standard deviation of the Gaussian filter which is employed 
%           to smooth the image. The greater sigma is, the more we smooth the image.   
%       thresh: The threshold employed by NMS.
%
%   Outputs:
%       M: The binary mask corresponding to the image's edge map.

% Reduce the effect of noise:
I = smooth_image(I, sigma); 

% Retrieve gradient magnitude and directions:
[X, Y] = image_gradient(I);
[R, Cos, Sin] = gradient_magnitude_direction(X, Y);
DirHead = interpolate_gradients(R, Cos, Sin);
DirTail = interpolate_gradients(R, -Cos, -Sin); % TODO: Check whether this is right or whether you need to feed X and Y in there instead.

% Build output matrix.
M = R > thresh & R > DirHead & R > DirTail;
end

% This method appears to be doing a better job than David's in the B & W
% swan image.