function predLabs = do_test(testData, testLabs, w, b, numCls, full_model)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

disp('Performing predictions based on learnt model...');
%scores = testData * w + ones(size(testData,1),numCls) * b;
%[~, predLabs] = max(scores, [], 2) ;

% Test Data matrix needs to be sparse for predict...
vals = testData(:);
rowInds = repmat((1:size(testData, 1))', size(testData, 2), 1); 
colInds = repmat((1:size(testData, 2))', 1, size(testData, 1));
colInds = colInds'; colInds = colInds(:);
testDataSp = sparse(rowInds, colInds, vals, size(testData, 1), size(testData, 2), numel(testData));
predLabs = predict(testLabs, testDataSp, full_model); % Will output an accuracy too.
acc=length(find(predLabs == testLabs)) ./ length(testLabs);
end

