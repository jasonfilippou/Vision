function [ M ] = hysteresis( I, sigma, t1, t2 )
%HYSTERESIS Perform hysteresis for edge detection. This is the last step of
%the Canny Edge detector.
%   Inputs:
%       I: The image, assumed to be a 'double' matrix.
%       sigma: The standard deviation of the Gaussian filter with which we will
%          smooth the image. The higher sigma is, the more we smooth the 
%          image.
%       t1: The first (high) threshold used by NMS.
%       t2: The second (low) threshold used by hysteresis.
%   Outputs:
%       M: The binary mask indicating the edge map of our image.

% Our implementation of hysteresis is based on a bottom-up approach which
% iteratively stitches edges together until it is no longer feasible to do
% so (by virtue of the thresholds). Unfortunately, because we need multiple 
% variables from our NMS routine "find_peaks", it makes much more sense to 
% copy the source code of NMS here instead of  modifying the function such 
% that it returns a larger list. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BEGIN NMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%  Same as in find_peaks.m  %%%%%%%%%%%%%%%%%%%%%%%

% Reduce the effect of noise:
I = smooth_image(I, sigma); 

% Retrieve gradient magnitude and directions:
[X, Y] = image_gradient(I);
[R, Cos, Sin] = gradient_magnitude_direction(X, Y);
DirHead = interpolate_gradients(R, Cos, Sin);
DirTail = interpolate_gradients(R, -Cos, -Sin);

% Build 'hard edge' matrix.
M = R > t1 & R > DirHead & R > DirTail;
%%%%%%%%%%%%%%%%%%%%%%%%%%% End of NMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Meat of the hysteresis algorithm.
CE = M; % CE = "Candidate Edges"
S = strel('square', 3);
while(any(CE(:))) % As long as at least one element is non-zero
    % Build a square of 1's around every 1 in M. Essentially CE will be 
    % a matrix of candidate edge pixels.
    CE = imdilate(M, S) - M; % We subtract the image from its morphological dilation
    CE = CE & (R > t2) & (R > DirHead) & (R > DirTail); % All candidates where threshold > t2 are admissible edges.
    M = M + CE; % Update edge map.
end
end

