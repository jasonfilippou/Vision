function J = interpolate_gradients(R, Dx, Dy)
% INTERPOLATE_GRADIENTS Given the magnitude of the image gradients, as well
% as its x and y components, interpolate them in the 8 directions possible
% in a discrete 2D image.
%
%   Inputs:
%       R:  A h x w matrix containing the magnitude of the image
%           gradients, where h and w are the height and width of the image, 
%           respectively.  
%       Dx, Dy: h x w matrices, containing the x and y components of the 
%           direction of the gradient. w and h are the dimensions of the image.  
%   Outputs:
%       J: A w x h matrix, where w and h are the dimensions of the image.  
%           J(i,j) contains the magnitude of the gradient at position (i+Dx(i,j), 
%           j+Dy(i,j)).  Of course, i+Dx(i,j) and j+Dy(i,j) are not integer positions; 
%           this is why we need to interpolate.
[h, w] = size(R);
X = (ones(h,1)*(1:w)) + Dx;
Y = ((1:h)'*ones(1,w)) + Dy;
J = interp2(R, X, Y); 

