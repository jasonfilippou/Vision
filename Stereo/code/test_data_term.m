% Script that ensures unary_cost and potts_cost are working
% correctly. Builds test images on the fly.

fprintf('Running tests for data term.\n');
% Test1
L = ones(100, 2);
R = [zeros(100, 1), ones(100, 1)];
INF_VAL = 2; % Maximum intensity difference is 1, so inf = 2 makes sense.
D = unary_cost(L, R, 1, INF_VAL); % MAXD=1, so intensities = 0 and 1
% The first column of the result for d= 0 should be one. 
% The second one, though, should be 0.
M=(D(:,:,1) == [ones(100,1), zeros(100, 1)]);
assert(all(M(:)));
% For d = 1, the result should be: INF in the first column, 1 in the
% second.
M=(D(:,:,2) == [ones(100,1).*INF_VAL, ones(100, 1)]);
assert(all(M(:)));
fprintf('Test 1 passed.\n');

% Test2
L = [ones(100, 1), zeros(100, 1), ones(100, 1), zeros(100, 1)];
R = circshift(L, 1, 2);
D = unary_cost(L, R, 3, INF_VAL); % possible disparities = 0, 1, 2, 3
% Asserting the expected disparity maps.
M=(D(:, :, 1) == ones(100, 4));
assert(all(M(:)));
M=(D(:, :, 2) == [ones(100, 1) .* INF_VAL, zeros(100, 3)]);
assert(all(M(:)));
M=(D(:, :, 3) == [ones(100, 2) .* INF_VAL, ones(100, 2)]);
assert(all(M(:)));
M=(D(:, :, 4) == [ones(100, 3) .* INF_VAL, zeros(100, 1)]);
fprintf('Test 2 passed.\n');
fprintf('Tests for data term passed.\n');