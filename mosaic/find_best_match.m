function [ best_matches ] = find_best_match( FT, DT, FS, DS )
%FIND_BEST_MATCHES Find the best matches between SIFT histograms encoded in
%the columns of DT and DS. The comparison between SIFT histograms is done
%via SSD. Uses two local routines.
%   Inputs: 
%           FT: a 4 x n matrix with first image keypoint representations in 
%               its columns. The keypoint representation includes the x and 
%               y coordinates, as well as orientation and scale parameters.
%           DT: a 128 x n matrix with the SIFT histograms for every one of
%               the n keypoints for the first image in its columnsin its 
%               columns. 
%           FS: The FT equivalent for the second (source) image.
%           DS: The DT equivalent for the second (source) image.
%   Outputs:
%           best_matches: An n x 5 matrix containing the matches sorted by
%               their score. The rows contain the match representation, which
%               consists of two pairs of x and y coordinates for the points matched,
%               as well as the SSD between the points' SIFT histograms.
%               Since match scoring is based on SSD,the smaller the
%               better, which is why the matrix is sorted on rows in
%               ascending order. 

best_matches = zeros(size(FS, 2), 5);
[matches, scores] = find_all_matches(DT, DS);
[~, I] = sort(scores);
for i = 1:size(FS, 2)
    best_matches(i, :) = [FS(1:2, I(i))', FT(1:2, matches(I(i)))', scores(I(i))];
end
end

function [ matches, scores ] = find_all_matches(DT, DS)
%FIND_ALL_MATCHES Find all matches between the histograms in the columns of
%DT and DS. Also return the scores of these matches, based on SSD.
matches = zeros(1, size(DS, 2));
scores = zeros(1, size(DS, 2));
for i = 1:size(DS, 2)
    [matches(i), scores(i)] = SSD(DT, DS(:, i));
end
end

function [ind, dist] = SSD(DT, D)
%SSD Compute the SSD between D and every column of DT, and return the smallest
% distance as well as the index of the column for which said smallest
% distance was detected.

R = repmat(D, 1, size(DT, 2));
dists = sum((double(R) - double(DT)).^2, 1);
[dist, ind] = min(dists);
end

