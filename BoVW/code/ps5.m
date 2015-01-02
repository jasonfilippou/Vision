% Problem Set 5
% Bag of visual words classification
% part of this code is adapted from vlfeat software package:
% http://www.vlfeat.org/

function ps5(TrainRatio, numWords, dictRatioPerClass, choice, featureMethod, encodingMethod)
% PS5 Top-level method for 5th problem set of CMSC733, Fall 2014. Runs a
% BoVW multi-class classification task on the Caltech 101 dataset, with
% parameters of the task set in its arguments. The underlying
% classification model is a multi-class L2-regularized SVM.
%
%   Inputs:
%       TrainRatio: The ratio of class examples to train the SVM on.
%       numWords: The number of visual words to consider for the dictionary learning step   
%       dictRatioPerClass: Ratio of class instances to use for training the
%           dictionary.
%       choice: Integer range which specifies the Caltech classes to train
%           a classification model on. The range depends on the output of
%           MATLAB's "dir" command and is thus system-dependent; for this
%           reason, we either suggest knowledge of what "dir" does on your
%           system or specifying 1:101 to train on the entire dataset
%       featureMethod: A string describing the feature space to extract
%           form the Caltech images. Currently, only 'sift' or 'filterBank' are
%           supported.
%       encodingMethod: A string which describes how to encode a given
%           training or testing pattern given the learnt dictionary.
%           Currently, only 'nn' (for nearest neighbor) or 'le' (for local
%           encoding) are supported as inputs.

% If the user calls the function as if it were a script, use the default
% problem set-up provided to us by the instructors.
if nargin == 0 
    TrainRatio = 0.5;
    dictRatioPerClass = 0.5;
    numWords = 600;
    choice = 76:80;
    featureMethod = 'sift';
    encodingMethod = 'nn';
end

% path to vlfeat
%addpath(genpath('vlfeat-0.9.19'));
run vlfeat-0.9.19/toolbox/vl_setup.m;
% path to liblinear
addpath(genpath('./liblinear-1.96'));
% path to Caltech 101 data
dataDir = '../images/101_ObjectCategories/';

disp(['Feature method: ' featureMethod ', Encoding method: ' encodingMethod]);

%% Read data
% cls are class names
cls = dir(dataDir);
cls = {cls(choice).name};
numCls = length(cls);

% Train and Test are structure that stored training and testing data
% Train{c}{i} stores descriptors for image i in class c
% we use cell array because number of descriptors for each image might be
% different!
Train = struct;
Test = struct;

% store descriptor for each class
Train.descrs = cell(numCls,1);
Test.descrs = cell(numCls,1);

% for each class
for c = 1:numCls
    % read image files
    disp(['Class ' cls{c}]);
    imgs = dir(fullfile(dataDir,cls{c},'*.jpg'));
    
    % prepare training index for each class, do this randomly
    numImgs = length(imgs);
    idx = randperm(numImgs);
    TrainIdx = idx(1:floor(TrainRatio*numImgs));
    TestIdx = idx(floor(TrainRatio*numImgs)+1:end);
    
    imgs = cellfun(@(x)fullfile(cls{c},x),{imgs.name},'UniformOutput',false) ;
    
    % extract features for training and testing
    Train.descrs{c} = cell(length(TrainIdx),1);
    disp('Collect training descriptors...')
    for i = 1:length(TrainIdx)
        im = imread([dataDir,imgs{TrainIdx(i)}]);
        %%%%%%%%%%%%%%%% TODO: write computeFeature that compute descriptor
        %%%%%%%%%%%%%%%% for given image
        Train.descrs{c}{i} = computeFeature(im,featureMethod);% sift or filterBank
    end
    
    Test.descrs{c} = cell(length(TestIdx),1);
    disp('Collect testing descriptors...')   
    for i = 1:length(TestIdx)
        im = imread([dataDir,imgs{TestIdx(i)}]);
        Test.descrs{c}{i} = computeFeature(im,featureMethod);% sift or filterBank
    end
end   


%% Build dictionary

%%%%%%%%%%%%%%%% TODO: write getVocab to learn vocab
vocab = getVocab(numCls,Train,dictRatioPerClass,numWords);


%% Encoding and representaion for each image
% Train.rep, Test.rep are representations for images, in our case
% histograms
Train.rep = cell(numCls,1);
Test.rep = cell(numCls,1);
for c = 1:numCls
    % for Train
    Train.rep{c} = zeros(length(Train.descrs{c}),numWords);
    for i=1:length(Train.descrs{c})% each image
    %%%%%%%%%%%%%%%% TODO: write encoding() that calculate histogram
    %%%%%%%%%%%%%%%% representation of an image given leared
    %%%%%%%%%%%%%%%% vocabulary/dictionary
        Train.rep{c}(i,:) = encoding(vocab,Train.descrs{c}{i},numWords,encodingMethod);% nearest neighbor or local encoding
    end
    % for Test
    Test.rep{c} = zeros(length(Test.descrs{c}),numWords);    
    for i=1:length(Test.descrs{c})
        Test.rep{c}(i,:) = encoding(vocab,Test.descrs{c}{i},numWords,encodingMethod);% nearest neighbor or local encoding
    end
end



%% Training using SVM

% concat all class together
TrainData = cat(1,Train.rep{:});
TrainLabel = cell(numCls);
for c=1:numCls
    TrainLabel{c} = c*ones(size(Train.rep{c},1),1);
end
TrainLabel = cat(1,TrainLabel{:});

%%%%%%%%%%%%%%%% TODO: use liblinear to learn a linear SVM
[w,b, full_model] = trainSVM(TrainData,TrainLabel);
showConfus(TrainData, TrainLabel, numCls, w, b, cls);

%% Testing
%%%%%%%%%%%%%%%% TODO: now test your classifier on test data
% Do the same concatenation for testing data
TestData = cat(1,Test.rep{:});
TestLabel = cell(numCls);
for c=1:numCls
    TestLabel{c} = c*ones(size(Test.rep{c},1),1);
end
TestLabel = cat(1,TestLabel{:});
% disp('Scaling testing data in [0, 1].');
% TestData = scale_matrix(TestData, 1);
predLabs = do_test(TestData, TestLabel, full_model);
showConfus(TestData, TestLabel, numCls, w, b, cls);
end

% function to show confusion matrix, you must have vlfeat to run this!
function showConfus(data,label,numCls,w,b,cls)

% evaluate training
scores = data * w + ones(size(data,1),numCls) * b;
[~, predictLabel] = max(scores, [], 2) ;

% Compute the confusion matrix
idx = sub2ind([numCls, numCls], ...
              label', predictLabel') ;
confus = zeros(numCls) ;
confus = vl_binsum(confus, ones(size(idx)), idx) ;

% Compute the accuracy
indicator = find(label == predictLabel);
accuracy = length(indicator)/length(label);

% Plots
figure ; clf;
subplot(1,2,1) ;
imagesc(scores); title('Scores') ;
set(gca, 'ytick', 1:size(data,1), 'yticklabel', label) ;
subplot(1,2,2) ;
confus = confus./(repmat(sum(confus,2),[1,numCls]));
imagesc(confus) ;
title(sprintf('Confusion matrix (%.2f %% accuracy)', ...
              100 * accuracy )) ;
          
% Show Accuracy
disp('Accuracy across classes:');
for c=1:numCls
    disp([cls{c} ':' num2str(100*confus(c,c)) '%']);
end

end
