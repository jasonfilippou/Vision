function [ D ] = SSD( T, S, M )
%SSD Compute the Sum of Squared Differences (SSD) between the provided
%template T and every pixel of the sample S. The binary mask M indicates
%which pixels in T have already been set and which have not.
%   Inputs:
%       T: an odd-sized square template of pixels, potentially partially
%       filled.
%       S: A texture sample (an image).
%       M: A binary mask indicating which pixels of T have already been filled
%       in.
%   Outputs:
%       D: A double array of the same size as S. D(i, j) contains the sum
%       of squared differences between S(i, j) and every pixel in T.

% Sanity check
if(size(T) ~= size(M))
    err = MException('ArgCheck:badArgs', 'The binary mask should have the same size as the template.');
    throw(err);
end

if( mod (size(T, 1), 2) == 0 || size(T, 1) ~= size(T, 2))
    err = MException('ArgCheck:badArgs', 'Need an odd-sized square template.');
    throw(err);
end

D = zeros(size(S, 1), size(S, 2));
n = length(M(M~=0)); % Number of non-zeros to normalize with
T = T .* M; % Need to apply only parts of template that are relevant, given the binary mask.

% Correlation computation is easy:
corrMat = xcorr2(S, T);
%Chop down the result of correlation to reflect the dimensions of S.
r = size(corrMat, 1);
c = size(corrMat, 2);
f = size(T, 1);
corrMat = corrMat((f + 1) / 2: r - (f - 1)/2, (f + 1) / 2: c - (f - 1)/2);

% The hardest part is the following. Compute the enveloping squares for every pixel,
% take the sum of squared elements for both the enveloping square elements
% and the template elements and subtract twice the respective correlation value.
for i = 1:size(S, 1)
    for j = 1:size(S, 2)
        W = build_square(S, i, j, size(T, 1)); % Call our method for producing a square around a given image pixel. Takes care of image boundaries.
        Temp = (W .* M).^2 + T.^2; % Notice that we are applying the mask again, this time on the first term.
        D(i, j) = sum(Temp(:)) - 2*corrMat(i, j); 
    end
end
D = D / n;
end