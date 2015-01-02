function display_sift_features(F, m)
% DISPLAY_SIFT_FEATURES: Display SIFT features on an image already shown
% displayed through imshow(). 
%
%   Inputs:
%       F: A 4 x N matrix where column j contains the x and y positions of 
%           the detected descriptor, as well as its scale and orientation
%           in radians. This information is returned by vl_sift. For more 
%           information, see  the documentation of that method: http://www.vlfeat.org/matlab/vl_sift.html
%       m: A string containing the parameters for plotting those features.
%           If omitted, code defaults to a red circle being plotted per SIFT
%           feature. 

% Note: This function was provided by the CMSC733 instructors for PS3.
if nargin < 2
    m = 'ro';
end
hold on
for i = 1:size(F,2)
    plot(F(1,i), F(2,i), m, 'MarkerSize', F(3,i));
end
hold off
end