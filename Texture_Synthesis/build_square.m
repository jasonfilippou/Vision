function [ S ] = build_square(I, i, j, n)
%BUILD_SQUARE Create a square around pixel I(i,j) of an image I. The square is of
% dimensions n x n. Image boundaries are zero-padded.
%   Inputs:
%       I: a grayscale image read in memory through imread() and 
%           normalized in the interval [0, 1]
%       i: the row of the pixel
%       j: the column of the pixel
%       n: the width of the square to build.
%   Outputs:
%       S: An nxn square around the pixel I(i, j).

if(n >= size(I, 1) || n >= size(I, 2))
    err = MException('argCheck:badArgs', 'Square requested is too large for provided image');
    throw(err);
end

S = zeros(n, n);
x = 1; y = 1;
for ii = i-(n-1)/2:i+(n - 1)/2
    for jj = j-(n -1)/2:j+(n-1)/2
        if(ii < 1 || ii > size(I, 1))
            S(x, y) = 0; % zero-padding the image
        elseif(jj < 1  || jj > size(I, 2))
            S(x, y) = 0; % same
        else
            S(x, y) = I(ii, jj); % copy over
        end
        y=y+1; % move over to the right
    end
    x=x+1; % move down
    y = 1; % reset y
end
end