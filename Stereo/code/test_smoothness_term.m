% Test the smoothness term. Creates test images on the fly.

fprintf('Running tests for smoothness term.\n');
% Test 1 (intensity differences below 5; only INF and K values considered)
img = [2 1 ; 1 0];
K = 3; INF_VAL = 10;

P = potts_cost(img, K, INF_VAL);
bottom=P(:, :, 1);
top = P(:, :, 2);
right = P(:, :, 3);
left = P(:, :, 4);
Assertion = (bottom == [2*K, 2*K ; INF_VAL, INF_VAL]);
assert(all(Assertion(:)));
Assertion = (top == [INF_VAL, INF_VAL ; 2*K, 2*K]);
assert(all(Assertion(:)));
Assertion = (right == [2*K, INF_VAL ; 2*K, INF_VAL]);
assert(all(Assertion(:)));
Assertion = (left == [INF_VAL, 2*K ; INF_VAL, 2*K]);
assert(all(Assertion(:)));
fprintf('Test 1 passed.\n');

% Test 2 (intensity differences both above and below 5)

img = [20, 23, 26, 50; 30, 40, 41, 41; 80, 15, 40, 8];
K = 3; INF_VAL = 10;
P = potts_cost(img, K, INF_VAL);
bottom=P(:, :, 1);
top = P(:, :, 2);
right = P(:, :, 3);
left = P(:, :, 4);
Assertion =(bottom == [K K K K ; K K 2*K K; ones(1, 4).*INF_VAL]);
assert(all(Assertion(:)));
Assertion = (top == [ones(1, 4) .* INF_VAL ; ones(1, 4) .*  K ; K K 2*K K]);
assert(all(Assertion(:)));
Assertion = (right == [2*K 2*K K INF_VAL ; K 2*K 2*K INF_VAL; K K K INF_VAL]);
assert(all(Assertion(:)));
Assertion = (left == [INF_VAL 2*K 2*K K ; INF_VAL K 2*K 2*K ; INF_VAL K K K]);
assert(all(Assertion(:)));
fprintf('Test 2 passed.\n');
fprintf('Tests for smoothness term passed.\n');