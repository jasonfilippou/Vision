function show_3_best( M, TI, SI )
% SHOW_3_BEST Given an n x 5 matrix of matches sorted on the fifth element
% of every row, visually plot the top 3 matches on both TI and SI.
%   Inputs: 
%       M: An n x 5 matrix, where n is the number of SIFT-based matches
%           between image keypoints. The rows contain the pairs of x and y
%           coordinates of the matched keypoints, and the 5th cell of every
%           row is the score of the match, on which the matrix is sorted.
%
%       TI: The 'target' image to overlay our point plotting on.
%       SI: The 'source' image to overlay our point plotting on.

M = M(1:3, :); % Take top three rows of M
figure; imshow(SI); % Source image
hold on;
plot(M(1,1), M(1,2), 'r.', 'MarkerSize', 20);
plot(M(2,1), M(2,2), 'b.', 'MarkerSize', 20);
plot(M(3,1), M(3,2), 'g.', 'MarkerSize', 20);
hold off;

figure; imshow(TI); % Target image
hold on;
plot(M(1,3), M(1,4), 'r.', 'MarkerSize', 20);
plot(M(2,3), M(2,4), 'b.', 'MarkerSize', 20);
plot(M(3,3), M(3,4), 'g.', 'MarkerSize', 20);
hold off;

end

