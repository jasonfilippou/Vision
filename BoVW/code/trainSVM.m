function [ w, b, model] = trainSVM( trainData,trainLabel)
%TRAINSVM Train a linear SVM using liblinear (or libSVM with an RBF kernel,
%   should time allow).
%   Inputs:
%       trainData: An N x D matrix with N patterns in its rows. D is the
%           number of codewords given in the BoVW encoding of the training
%           data.
%       trainLabel: An N x 1 vector of Caltech 101 training labels.
%
%   Outputs:    
%       w: The weight vector learnt by the classifier.
%       b: The bias term learnt by the classifier. 
%       model: The struct returned by the "train" method of LIBLINEAR. This
%           could be ommitted as a return value since the set {w, b} fully
%           characterizes a linear SVM classifier (in the primal form), but
%           the "predict" function of LIBLINEAR, used later on in the
%           project, needs the full structure to operate.

% Data Matrix needs to be sparse....
vals = trainData(:);
rowInds = repmat((1:size(trainData, 1))', size(trainData, 2), 1); 
colInds = repmat((1:size(trainData, 2))', 1, size(trainData, 1));
colInds = colInds'; colInds = colInds(:);
TrainDataSp = sparse(rowInds, colInds, vals, size(trainData, 1), size(trainData, 2), numel(trainData));
disp('Training SVM...');
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
model = train(trainLabel, TrainDataSp, weightParams); 
%model = train(trainLabel, TrainDataSp); 
w = model.w'; 
b = model.bias;
end
