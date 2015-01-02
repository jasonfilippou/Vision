function predLabs = do_test(testData, testLabs, full_model)
%DO_TEST Test the learnt model on testing data.
%   Inputs:
%       testData: An N x D matrix of test points, where N is the number of
%           test points and D is the length of their encoding given the visual
%           word vocabulary learnt.
%       testLabs: An N x 1 vector of class labels, 1 per test point.
%       full_model: The full classification model struct, returned by the
%           "train" method of liblinear.
%   Outputs:
%       predLabs: The labels predicted by the "predict" function of
%           liblinear

disp('Performing predictions based on learnt model...');
% Test Data matrix needs to be sparse before we send it to "predict"...
vals = testData(:);
rowInds = repmat((1:size(testData, 1))', size(testData, 2), 1); 
colInds = repmat((1:size(testData, 2))', 1, size(testData, 1));
colInds = colInds'; colInds = colInds(:);
testDataSp = sparse(rowInds, colInds, vals, size(testData, 1), size(testData, 2), numel(testData));
predLabs = predict(testLabs, testDataSp, full_model); % Will output an accuracy too, unless we specify the "-q" parameter.
end

