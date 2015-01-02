function [ I ] = grow_image(S, Wsize)
%GROW_IMAGE Implements the texture synthesis method of Efros and Leung for
% grayscale images.
%   Inputs:
%       S: The sample of the grayscale texture that we want to synthesize.
%       Wsize: A tuneable parameter, representing the window size to use
%           when matching a template to the sample. Small window sizes should 
%           be used for high-frequency textures, whereas large window sizes 
%           are suitable for more regular textures.
%    Outputs:
%       I: The synthesized texture.

% Sanity checking
if(mod(Wsize, 2) == 0) % Could be checking first dimension just as well
    err = MException('ArgCheck:badArgs', 'Window should be odd-sized');
    throw(err);
end

% Read inputs and create empty matrices
S = double((imread(S)));
if(length(size(S)) == 3)
    S = rgb2gray(S);
end

%Synthesizing an equi-sized texture for efficiency reasons.
I = zeros(size(S, 1), size(S, 2));  
M = zeros(size(S, 1), size(S, 2));

% OR, leave the laptop open all night and synthesize a larger texture...
%I = zeros(3*size(S, 1), 3*size(S, 2));  
%M = zeros(3*size(S, 1), 3*size(S, 2));

% Take a random Wsize-sized "seed" sample from the input picture and place it
% somewhere in the output picture. Both the sample picked as well as the
% actual position of the seed in the new image are going to be randomized.
maxX = size(S, 1) - (Wsize - 1) / 2; 
maxY = size(S, 2) - (Wsize - 1) / 2;
randX = randi(maxX, 1, 1) + (Wsize - 1) / 2;
randY = randi(maxY, 1, 1) + (Wsize - 1) / 2;
seed = build_square(S, randX, randY, Wsize); % guaranteed to take a square chunk of the image, without falling off the border, because of the uniform distribution limits.
randX = randi(maxX, 1, 1) + (Wsize - 1) / 2;
randY = randi(maxY, 1, 1) + (Wsize - 1) / 2;
I(randX : randX + Wsize - 1, randY: randY + Wsize - 1) = seed; % putting the seed in the new picture
M(randX : randX + Wsize - 1, randY: randY + Wsize - 1) = 1; % binary mask needs to reflect the fact that these pixels are now filled...

Threshold = 0.3; % Kind of trying to emulate what the authors did without using two different variables for thresholds...
while ~isempty(M(M == 0)) % so long as there are pixels to fill...
    fprintf('\tStill have %d unfilled pixels.\n', length(M(M==0))); % uncomment to monitor progress as a function of
    %decreasing # unfilled pixels.
    progress = false; % guilty until proven innocent
    pixelList = get_pixels_with_filled_neighbors(M); % self-explanatory
    for i = 1:size(pixelList, 1) % for all candidate pixels found in the texture under synthesis...
        template = build_square(I, pixelList(i, 1), pixelList(i, 2), Wsize); % build the template from the texture that is currently synthesized
        local_mask = build_square(M, pixelList(i, 1), pixelList(i, 2), Wsize); % and chop down the relevant part of the mask
        best_matches = find_matches(template, S, local_mask, Threshold); % find the matches of the template in the original texture
        if(~isempty(best_matches)) % If there was at least one pixel match from the template...
            selected_pixel = best_matches(randi(size(best_matches, 1), 1, 1), :); % Pick a random pixel from the best matched pixels
            I(pixelList(i, 1), pixelList(i, 2)) = S(selected_pixel(1), selected_pixel(2)); % Copy the pixel over
            M(pixelList(i, 1), pixelList(i,2)) = 1; % mark pixel as filled
            progress = true; % at least one match was found
        end
    end
    if(~progress) % we did not make any progress because the threshold was too tight.
        Threshold = Threshold * 1.1; % so, adapt it.
    end
end

end

function [PixelList] = get_pixels_with_filled_neighbors(M)
% GET_PIXELS_WITH_FILLED_NEIGHBORS Gets the non-filled pixels with 
%   filled neighbors. This is accomplished by subtracting the mask from its 
%   morphological dilation, where a 3 x 3 square of 1's is considered as the 
%   rectangle parameter.
%   Inputs:
%       M: A binary mask where 1's represent filled pixels and 0's represent
%       non-filld pixels.
%   Outputs:
%       PixelList: The list of non-filled pixels with at least one filled
%           neighbor, where neighbors are considered only pixel-wide. If we allowed
%           neighbors to be considered at a window-sized distance (see function
%           grow_image for the explanation of the window size parameter), then: 
%           (1)The PixelList would be very large and would impose a bottleneck 
%           for the algorithm and (2)the quality of the cdf approximation would be 
%           lower, because we would have less pixels to consider as our neighbors
%           (the local mask patch would have more 0s than 1s, at least initially).

MDil = imdilate(M, ones(3, 3));
Msub = MDil - M;
[i, j] = ind2sub([size(Msub, 1), size(Msub, 2)], find(Msub == 1));
PixelList = [i j];
end