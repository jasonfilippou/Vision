function [ vocab ] = getVocab( numCls,Train,dictRatioPerClass,numWords)
%GETVOCAB Generate a vocabulary of "numWords" vectors which effectively
%quantizes our training data.
% Inputs:
%   numCls: Integer scalar representing the #classes in our data.
%   Train: A MATLAB struct containing a c x 1 field called "descrs".
%       descrs{i} contains an I x 1 cell matrix, where I is the #images
%       corresponding to class i. Every element of that cell matrix points
%       to the feature matrix for the relevant image.
%   dictRatioPerClass: floating-point scalar dictating how many descriptors
%       from each class we should consider for building the dictionary. TODO:
%       clarify if this parameter should affect descriptors or images. It
%       currently affects descriptors.
%   numWords: An integer scalar dictating how many visual words the
%       dictionary will be made from.
% Outputs: %
%   vocab: A D x K matrix, where every column is a D-dimensional
%   dictionary element.
   
% Sanity checking 
assert(numCls > 1, 'Need at least one class.');
assert(numCls == length(Train.descrs), 'Mismatch between provided #classes and #classes in training data structure.');

% Collect the data to send to the k-means solver
data = cell(1, numCls);
for c =1:numCls % This can be vectorized through cellfun.
    data{c} = cell2mat(Train.descrs{c}(1:floor(dictRatioPerClass*length(Train.descrs{c})))'); % Tested.
end   

data = single(cell2mat(data));
% If the dimensionality of "data" is above 10K, randomly permute the 
% order of the features and chop it down to 10K. This makes k-means
% tractable.
if(size(data, 2) > 10^4)
    order = randperm(size(data, 2));
    data = data(:, order(1:10^4));
end
% For safety purposes, assert that the number of data elements is at least
% 10x the number of codewords we want to extract. It will be useful to flag
% cases where this does not occur.
assert(size(data, 2) >= 10*numWords, 'Patterns need to be at least ten times as many as the specified codewords.');

%Run k-means solver with k-means++ initialization
disp('Running k-means to learn vocabulary...');
[vocab, ~] = vl_kmeans(data, numWords, 'Initialization', 'plusplus');
end

