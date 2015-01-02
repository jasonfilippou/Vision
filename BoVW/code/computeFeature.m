function [ featVec ] = computeFeature( I, method )
%COMPUTEFEATURE Compute a feature vector for image I using one of two
%methods: "sift" or "filterBank".
%   Inputs:
%       I: The input image, assumed to have been read in via imread().
%       method: A string which specifies the feature extraction method to
%           be used. We support all case-insensitive combinations of "sift"
%           or "filterBank", with arbitrary amounts of whitespace before or
%           after the actual strings.
%   Outputs:
%       featVec: The output feature matrix. Dimensionality differs based on
%           "method".

% Doing case insensitive string comparisons with a switch statement is a
% pain, so we will opt for if-else instead.
method = strtrim(method);
if(strcmpi(method, 'sift') == 1)
    % Make sure the image is single...
    if(~isa(I, 'single'))
        I = im2single(I);
    end
    % Check if we were given an RGB image, in which case we will have to
    % change it with rgb2gray.
    if(length(size(I)) == 3)
        I = rgb2gray(I);
    end
    % All checks assured, now we can simply run vl_sift.
    %disp('Computing SIFT features...');
    [~, featVec] = vl_sift(I);
elseif (strcmpi(method, 'filterBank') == 1)
    %disp('Computing FilterBank features...');
    featVec = filterBank(I);
else
    disp('Only "sift" or "filterBank" methods are supported');
    featVec = Nan;
end
end

