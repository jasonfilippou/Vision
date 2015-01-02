function [ featVec ] = filterBank( I )
%FILTERBANK Compute filterBank features for image I.
%   Inputs:
%       I: The hxwx3 RGB image, assumed read in by imread().
%
%   Outputs:
%
%       featVec: The 17*h*w filterBank response vector.
%

% Necessary assertions / checks
% If the image is grayscale, we need to make it into a dummy RGB image
% to allow for RGB - to - L*a*b* space conversion.
if(length(size(I)) == 2)
    I = repmat(I, [1, 1, 3]);
end

% First, create all the filters.

% Gaussians
G1 = fspecial('gaussian', f(1), 1);
G2 = fspecial('gaussian', f(2), 2);
G3 = fspecial('gaussian', f(4), 4);

% Gradients of Gaussians
[DG1x, DG1y] = gradient(G1);
[DG2x, DG2y] = gradient(G2);

% LoG
LoG1 = fspecial('log', f(1), 1);
LoG2 = fspecial('log', f(2), 2);
LoG3 = fspecial('log', f(4), 4);
LoG4 = fspecial('log', f(8), 8);

% Now, convolve the appropriate image channels.
cform = makecform('srgb2lab');
Lab = applycform(I,cform); 
%Lab = rgb2lab(I); % This only works in later versions of MATLAB.
L = Lab(:, :, 1); a = Lab(:, :, 2); b = Lab(:, :, 3);
% We will create a 3D array whose number of "z-slices" will be 17. Every
% slice will correspond to an application of a different filter on specific
% color channels.
PixelResponses = zeros(size(I, 1), size(I, 2), 17);
% First 9 responses correspond to filtering the [L, a, b] channels with the
% 3 Gaussian filters.
PixelResponses(:, :, 1) = imfilter(L, G1, 'replicate');
PixelResponses(:, :, 2) = imfilter(L, G2, 'replicate');
PixelResponses(:, :, 3) = imfilter(L, G3, 'replicate');
PixelResponses(:, :, 4) = imfilter(a, G1, 'replicate');
PixelResponses(:, :, 5) = imfilter(a, G2, 'replicate');
PixelResponses(:, :, 6) = imfilter(a, G3, 'replicate');
PixelResponses(:, :, 7) = imfilter(b, G1, 'replicate');
PixelResponses(:, :, 8) = imfilter(b, G2, 'replicate');
PixelResponses(:, :, 9) = imfilter(b, G3, 'replicate');

% The next 4 ones correspond to filtering the L channel with the 4
% different LoG filters.
PixelResponses(:, :, 10) = imfilter(L, LoG1, 'replicate');
PixelResponses(:, :, 11) = imfilter(L, LoG2, 'replicate');
PixelResponses(:, :, 12) = imfilter(L, LoG3, 'replicate');
PixelResponses(:, :, 13) = imfilter(L, LoG4, 'replicate');

% The final 4 ones correspond to filtering the L channel with the 4
% derivative of Gaussian filters.
PixelResponses(:, :, 14) = imfilter(L, DG1x, 'replicate');
PixelResponses(:, :, 15) = imfilter(L, DG1y, 'replicate');
PixelResponses(:, :, 16) = imfilter(L, DG2x, 'replicate');
PixelResponses(:, :, 17) = imfilter(L, DG2y, 'replicate');

% Finally, aggregate filter responses per pixel to produce an 17 x (h * w)
% feature matrix.
%assert(size(PixelResponses, 1) == size(I, 1) && size(PixelResponses, 2) == size(I, 2));
featVec = reshape(PixelResponses, size(I, 1) * size(I, 2), 17)';
end

% Calculate the width of a Gaussian filter as a function of standard deviation.
function w = f(s)
w = 6*s + 1; % Captures almost the entirety of the Gaussian.
end