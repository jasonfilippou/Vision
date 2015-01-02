function P = potts_cost( L, K, INF_VAL )
%POTTS_COST Compute the potts smoothness cost as explained in the PAMI 2001
%paper.
%   Inputs:
%       L: The image to compute the cost over. Note that the Potts cost
%          is not a function of the right image.
%       K: The Potts constant.
%       INF_VAL: A value indicating an "infinite" cost, useful for
%       disallowing impossible matches.
%   Outputs:
%       P: A 3D matrix of dimensions h x w x 4. Every "z" dimension
%       contains the smoothness cost for every neighbor of the (i, j)
%       pixel, going clockwise from top, right, bottom, left.

% Initialize output matrix.
P = zeros(size(L, 1), size(L, 2), 4);

% 1st (every pixel compared with its bottom neighbor)
P(1:end-1, :, 1) = abs(L(1:end-1, :) - L(2:end, :));

% Fill in 2nd dimension (every pixel compared with its top neighbor)
P(2:end, :, 2) = abs(L(2:end, :) - L(1:end-1, :));

% 3rd dimension (every pixel compared with its right neighbor)
P(:, 1:end-1, 3) = abs(L(:,1:end-1) - L(:, 2:end)); 

% 4th (every pixel compared with its left neighbor)
P(:, 2:end, 4) = abs(L(:,2:end) - L(:, 1:end-1)); 

% Setup P appropriately, including infinite costs.
ind=P<=5; % Wondering whether this static cost of 5 is universally appropriate...
P(ind)=2*K;
P(~ind)=K;
P(end, :, 1) = INF_VAL; % No bottom neighbors for bottom row
P(1, :, 2) = INF_VAL; % No top ....
P(:, end, 3) = INF_VAL; % Right...
P(:, 1, 4) = INF_VAL; % Left...
end

