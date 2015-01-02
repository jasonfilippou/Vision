function do_test_both(testData, testLabs, linear_model, non_linear_model)
%DO_TEST_BOTH Test the learnt linear and non-linear models on testing data.
%   Inputs:
%       testData: An N x D matrix of test points, where N is the number of
%           test points and D is the length of their encoding given the visual
%           word vocabulary learnt.
%       testLabs: An N x 1 vector of class labels, 1 per test point.
%       linear_model: The linear classification model struct, returned by the
%           "train" method of liblinear.
%       non_linear_model: The non-linear classification model struct,
%       returned by the "svm_train" method of libsvm.

disp('Predictions of linear model:');
% Test Data matrix needs to be sparse before we send it to "predict"...
vals = testData(:);
rowInds = repmat((1:size(testData, 1))', size(testData, 2), 1); 
colInds = repmat((1:size(testData, 2))', 1, size(testData, 1));
colInds = colInds'; colInds = colInds(:);
testDataSp = sparse(rowInds, colInds, vals, size(testData, 1), size(testData, 2), numel(testData));
predict(testLabs, testDataSp, linear_model); % Will output an accuracy too, unless we specify the "-q" parameter.
disp('Predictions of non-linear model:');
[~, acc, ~] = svmpredict(testLabs, testData, non_linear_model);
end

