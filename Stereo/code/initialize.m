function D = initialize(data_term)
%INITIALIZE Initialize the disparities for the a-b swap problem by 
% optimizing the data term only.
%   Inputs:
%       data_term: An h x w x MAXD matrix containing the data term for the
%           stereo matching problem. data_term(i, j, k) = (L(i,j) - R(i,
%           j-k))^2.
%   Outputs:
%       D: The initial disparity map computed by this step.
%
% Since we only optimize over the data term, this is a one-liner.
[~, D] = min(data_term, [], 3);
end