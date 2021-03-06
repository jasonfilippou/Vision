function [ Dx, Dy ] = image_gradient( I )
%IMAGE_GRADIENT Computes the horizontal and vertical components of the
%image gradient of the image provided.
%   Inputs:
%       I: an image in the form of a 2D matrix of double values.
%   Outputs:
%       Dx: the horizontal component of the gradient at every pixel.
%       Dy: the vertical component of the gradient at every pixel.

% Replicate matrix twice to make conv2 operate on a pixel-padded image...
% Exactly why they haven't incorporated this functionality in conv/conv2 is
% beyond me.
Ir = padarray(I, [0, 1], 'replicate');
Dx = conv2(Ir, [0.5, 0, -0.5], 'same');

% Drop first and last columns spuriously created with padarray to support
% proper convolution...
Dx(:, 1) = [];
Dx(:, size(Dx, 2)) = [];

% Do the same thing along the y direction.
Ic = padarray(I, [1, 0], 'replicate');
Dy = conv2(Ic, [0.5, 0, -0.5]', 'same');
Dy(1, :) = [];
Dy(size(Dy, 1), :) = [];
end

% TODO: The function 'imgradientxy' essentially does what I'm doing in this function.
% However, I noticed that both the 'CentralDifference' and 'IntermediateDifference'
% flags, corresponding to different order approximations of the Taylor
% Series solution to the 1D diffusion equation, give you the same result... 
% This has been observed on 2013b, 2014a and 2014b. Could be a bug in the
% Image Processing toolbox.
% [Dx, Dy] = imgradientxy(I, 'CentralDifference'); 
