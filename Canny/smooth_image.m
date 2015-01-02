function [ S ] = smooth_image( I, sigma )
%SMOOTH_IMAGE Smooths a B & W image by performing convolution with a Gaussian
% filter of the provided standard deviation.
%   Inputs:
%       I: input B & W image in 2D matrix format.
%       sigma: scalar representing the standard deviation of the Gaussian
%       filter. Essentially controls the amount of smoothing.
%   Outputs:
%       S: The smoothed image.

w = 6 * ceil(sigma) + 1; % guaranteed to hold interval (-3*s, +3*s).
f = fspecial('gaussian', [w, w], sigma);
S = imfilter(I, f, 'replicate');
end

