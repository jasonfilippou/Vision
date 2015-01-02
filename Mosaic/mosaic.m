function I_st = mosaic(J, K)
%MOSAIC Perform mosaicing between two images J and K.
%   Inputs:
%       J, K: Images.
%   Outputs:
%       I_st: J and K stitched into a single image.

% 1: Extract SIFT features
[F1, D1] = vl_sift(single(J));
[F2, D2] = vl_sift(single(K));
fprintf('SIFT features extracted\n');

% 2: Match features from the two pictures.
M = find_best_match(F1, D1, F2, D2);
fprintf('Matches computed\n');

% 3: Run RANSAC to compute the optimal affine transformation that matches
% the second picture onto the first one.
Aopt = ransac(M);
fprintf('RANSAC run.\n');

% 4: Stitch the two pictures given this optimal transformation, returning
% the result to the caller.
[I_st, ~] = stitch(K, J, Aopt);
fprintf('Stitched pictures together.\n');
end

