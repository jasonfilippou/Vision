function e = encoding( vocab, imageFeats, numWords, method)
%ENCODING Encode the examples in "imageFeats" according to "method" given a
%   vocabulary "vocab" of "numWords" visual words.
%  INPUTS:
%       vocab
%       imageFeats
%       numWords
%  OUTPUTS:
%       e

e = zeros(numWords, 1); % Make it a column vector for storage/accessing efficiency

imageFeats = single(imageFeats); % SIFT features are stored as uint8s, while the 

% The squared Eucliduean distance between every image descriptor and every
% vocabulary element will be required by either approach. Therefore, we
% will precompute it before querying about the exact method employed. The
% format will be a V x F matrix "sqDistances" where sqDistances(i, j) is
% the squared distance between codeword i and descriptor j.
sqDistances = zeros(size(vocab, 2), size(imageFeats, 2));
for f = 1:size(imageFeats, 2) 
    diff = vocab - repmat(imageFeats(:, f), 1, size(vocab, 2));
    sqDistances(:, f) = sum(diff.^2, 1);
end

% Now branch off to either method
method = strtrim(method);
if(strcmpi(method, 'nn') == 1) % nearest neighbor (peaked, degenerate  histogram)
    % Assign every descriptor to the element to which it is closest.
    [~, ind] = min(sqDistances); 
    tempMat = zeros(size(sqDistances));
    tempMat(sub2ind(size(sqDistances), ind, 1:length(ind))) = 1;
    % Calculate the encoding as the normalized histogram of codeword
    % assignments.
    e = sum(tempMat, 2); % Calculates the #times that every codeword was found to be representative of some descriptor.
elseif(strcmpi(method, 'le') == 1) % local encoding (smooth histogram)
    sqDistances = exp(-sqrt(sqDistances) ./ 2); %Fitting Gaussian kernel with stddev = 1
    %sqDistances = 10 .* exp(-sqrt(sqDistances));
    e = sum(sqDistances, 2); % Soft assignment is easier with the appropriate distance metric.
end
e = e/sum(e); % Normalize
end

