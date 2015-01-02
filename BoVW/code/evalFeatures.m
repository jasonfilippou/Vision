% Evaluate the features extracted from both SIFT and Filterbank on the
% built-in "peppers" image.

% SIFT
I = imread('peppers.png');
run vlfeat-0.9.19/toolbox/vl_setup.m;
[locs, ~] = vl_sift(im2single(rgb2gray(I))); % I want to go home
h=figure; imshow(I, []); % Don't need to imshow it in grayscale for the features to be properly overlain...
display_sift_features(locs);
print(h, '-dpng', '../images/peppersSIFT.png');

%FilterBank
fbFeats = filterBank(I);
for i = 1:size(fbFeats, 1)
    h=figure; imshow(reshape(fbFeats(i, :), size(rgb2gray(I))), []); % I wanna go home to play the bass, goddammit
    print(h, '-dpng', sprintf('../images/peppersFB_c%d.png', i));
end