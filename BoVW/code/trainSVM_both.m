function [modellinear, modelrbf] = trainSVM_both( trainData,trainLabel)
%TRAINSVM Train a linear SVM using liblinear and a cross-validated non-linear
%   SVM with an RBF  kernel using libsvm.
%   Inputs:
%       trainData: An N x D matrix with N patterns in its rows. D is the
%           number of codewords given in the BoVW encoding of the training
%           data.
%       trainLabel: An N x 1 vector of Caltech 101 training labels.
%
%   Outputs:    
%       w: The weight vector learnt by the classifier.
%       b: The bias term learnt by the classifier. 
%       modellinear: The struct returned by the "train" method of LIBLINEAR.
%       modelrbf: The struct returned by the "svmtrain" method of LIBSVM.

% Data Matrix needs to be sparse for libSVM....
vals = trainData(:);
rowInds = repmat((1:size(trainData, 1))', size(trainData, 2), 1); 
colInds = repmat((1:size(trainData, 2))', 1, size(trainData, 1));
colInds = colInds'; colInds = colInds(:);
TrainDataSp = sparse(rowInds, colInds, vals, size(trainData, 1), size(trainData, 2), numel(trainData));
disp('Training linear SVM...');
% Since LIBLINEAR does OVA classification, it might be beneficial if we
% figure out the training instance imbalance and rectify it by adjusting
% the learning problem's weights.
uniqueLabs = unique(trainLabel);
weightParams = '';
for l = 1:length(uniqueLabs)
    lab = uniqueLabs(l);
    assert(sum(trainLabel == lab) < sum(trainLabel ~= lab) ./ 2, sprintf('Class label %d appears to be dominating in the label set.', lab));
    weight = sum(trainLabel ~= lab) ./ sum(trainLabel == lab);
    weightParams = [weightParams, sprintf('-w%d %.2f ', lab, weight)];
end
params = strcat(weightParams, ' -q');
modellinear = train(trainLabel, TrainDataSp, params); 
disp('Linear SVM trained.');
% Now time to train libSVM model
disp('Training non-linear SVM with cross-validation...');
params = strcat(weightParams, ' -v 10 -q');
% I don't think it's correct to weight classes in LIBSVM, since it does AVA classification. 
% Let's run an experiment without any class weighting.
%params = '-v 10 -q';
modelrbf = svmtrain(trainLabel, trainData, params);
disp('Non-linear SVM trained.');
end
