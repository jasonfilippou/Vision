function D = stereo( L, R )
%STEREO Stereo matching using graph cuts.
%
%   Inputs:cp -
%       L: The left image.
%       R: The right image, assumed rectified with the left image.
%   Outputs:
%       D: The disparity map computed between L and R.

% Boykov et al. use 15 different intensities when they solve for the
% Tsokuba images, so we will use that value as well.
MAXD=15;

% They also report some results by using a value of K=20 for the potts
% model parameter, so we follow their lead:
K=20;

% Finally, we need to come up with an appropriate value for INF. 
% maximum penalty incurred by the Potts model is 2K = 40. If we assume that
% the possible Ks will not deviate from that small range, the maximum
% possible difference in intensity (255^2) by far overshadows 2K. Therefore,
% we will define INF with that particular number in mind.
INF_VAL = 255^2 + 1; % No smoothness or unary cost can be larger than this.

% We now have all the constants necessary to run stereo matching.
data_term = unary_cost(L, R, MAXD, INF_VAL);
fprintf('Data term computed.\n');
smoothness_term = potts_cost(L, K, INF_VAL);
fprintf('Smoothness term computed.\n');
D = initialize(data_term);
fprintf('Disparities initialized.\n');
D = ab_swap(D, data_term, smoothness_term, MAXD);
fprintf('A-B swap run.\n');
end

