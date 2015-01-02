function run_mosaic(pnum)
% RUN_MOSAIC Executes the deliverables for part 2 of the third CMSC 733
% programming project, Fall 2014. Implements Image Mosaicing with RANSAC.
%   Inputs:
%       pnum: An integer switch that guides the execution down different
%               paths.

% We need SIFT feature extraction for mosaicing, so we compile and link
% VLfeat alongside the rest of the submission.
run('vlfeat-0.9.19/toolbox/vl_setup');
switch pnum
    case 1
        I = single(zeros(100,100));
        I(40:60,40:60) = 255;
	  % Testing SIFT with a white square on a black background.
        [F, D] = vl_sift(I);
        figure;
        imshow(I);
        display_sift_features(F);
        
	  % Testing SIFT with images we provide.
        J = imread('LR1bw.jpg');
        [F2, D2] = vl_sift(single(J));
        figure;
        imshow(J);
        display_sift_features(F2);
        
        K = imread('LR2bw.jpg');
        [F3, D3] = vl_sift(single(K));
        figure;
        imshow(K);
        display_sift_features(F3);
        
    case 2
        J = imread('LR1bw.jpg');
        [F2, D2] = vl_sift(single(J));
        K = imread('LR2bw.jpg');
        [F3, D3] = vl_sift(single(K));
        M = find_best_match(F2, D2, F3, D3);
        show_3_best(M, J, K);
       
    case 3
        p1 = rand(2,3);
        p2 = rand(2,3);
        A = affine_transformation(p1,p2);
        p2 - A*[p1; ones(1,3)] % Almost zero, let it show on the cmd
        
    case 4
        p1 = 100*rand(2,8);
        A = 100*rand(2,3);
        p2 = A*[p1; ones(1,8)];
	  % Points in p2 match p1 perfectly using A.
        p1 = [p1, 100*rand(2,16)];
        p2 = [p2, 100*rand(2,16)];
	  % Now we've added some noisy points that don't match.
        M = [p2', p1'];
        Ares = ransac(M);
        A, Ares
	  % A and Ares should be the same, since the best affine
	  % transformation will match the first 8 points of p1 and p2.
      % Note that if the #iterations of RANSAC is too low, this
      % is not guaranteed to happen. I've tested this with #iter=1000.
    case 5
        J = imread('LR1bw.jpg');
        K = imread('LR2bw.jpg');
        A1 = translate100; % In the +x direction.
        [Is1, ~,] = stitch(J, K, A1);
        figure;
        imshow(uint8(Is1));
        A2 = trs; % Translation, rotation and scaling as described in the problem set description.
        [Is2, ~,] = stitch(J, K, A2);
        figure;
        imshow(uint8(Is2));
    case 6
        J = rgb2gray(imread('LR1bw.png'));
        K = rgb2gray(imread('LR2bw.png'));
        Im = mosaic(J, K); % Full mosaicing
        figure;
        imshow(uint8(Im));
    case 7
        % (1) Mosaic the original image and its transformation under "trs".
        J = rgb2gray(imread('LR1bw.png'));
        K = rgb2gray(imread('figures/rotated_figure.jpg'));
        Im = mosaic(J, K);
        figure; imshow(J, []);
        figure; imshow(K, []);
        figure; imshow(Im, []);
        
        % (2) Mosaic a picture of the wall in my room by a translation.
        J = rgb2gray(imread('figures/room_l.png'));
        K = rgb2gray(imread('figures/room_r.png'));
        I_st = mosaic(J, K);
        figure; imshow(I_st, []);

        % (3) Use trs again on the same wall images.
        J = rgb2gray(imread('figures/room_l.png'));
        K = rgb2gray(imread('figures/room_trs.png'));
        I_st = mosaic(J, K);
        figure; imshow(I_st, []);
end

function display_sift_features(F, m)
% DISPLAY_SIFT_FEATURES Display SIFT features extracted via VLFeat
% on an image already displayed in a MATLAB figure (using, e.g., imshow)
%   Inputs:
%       F: a 4 x N matrix representing the (x, y) coordinates, orientation and scale 
%           of VLFeat-extracted SIFT features. Essentially the first return
%           argument of vl_sift.
%       m: Style of the marker used to display the features. Defaults to 'ro',
%           which produces red circles. 
if nargin < 2
    m = 'ro';
end
hold on
for i = 1:size(F,2)
    plot(F(1,i), F(2,i), m, 'MarkerSize', F(3,i));
end
hold off


