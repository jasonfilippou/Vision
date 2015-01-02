% Problem Set 5
% Bag of visual words classification
% part of this code is adapted from vlfeat software package:
% http://www.vlfeat.org/

function ps5(TrainRatio, numWords, dictRatioPerClass, choice, featureMethod, encodingMethod)

if nargin == 0 % set default problem set-up.
    % by default, half of images in each class is used for training
    TrainRatio = 0.5;
    % ratio for each class to build dictionary
    dictRatioPerClass = 0.5;
    % number of visual words in vocabulary
    numWords = 600;
    % take a subset of the Caltech 101 classes, change it to include more classes
    choice = 76:80;
    % method used for feature extraction, sift or filterBank
    featureMethod = 'sift';
    % method used for encoding, nn or le
    encodingMethod = 'nn';
end

% path to vlfeat
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
predLabs = do_test(TestData, TestLabel,w,b,numCls, full_model);
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
disp('Accuracy:');
for c=1:numCls
    disp([cls{c} ':' num2str(100*confus(c,c)) '%']);
end

end
