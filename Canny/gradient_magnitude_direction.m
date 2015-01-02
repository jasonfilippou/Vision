function [ R, X, Y ] = gradient_magnitude_direction( Dx, Dy )
%GRADIENT_MAGNITUDE_DIRECTION Compute the magnitude of the gradient, as
%well as the cosine and sine of its direction at every possible point.
%   Dx = x component of gradient.
%   Dy = y component of gradient.
%   R = matrix of the same size as the image, containing the gradient
%   magnitudes at every pixel.
%   X = cosine of the angle of the gradient vector at every pixel.
%   Y = sine of the angle of the gradient vector at every pixel.

R = sqrt(Dx .^ 2 + Dy .^2);
X = Dx ./ R;
Y = Dy ./ R;
end

