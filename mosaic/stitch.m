function [stitched_image, stitched_mask] = stitch(im1, im2, T_im2, mask)
% STITCH Given two images im1 and im2 and a transformation T_im2 that shall
% be applied to im2, this function computes a composite image and a mask. 
% The mask 'stitched_mask' is a matrix of the same dimensions as the 
% resulting image whose pixel values are the number of image layers on each 
% pixel.Upon subsequent calls, previously calculated masks have to be fed 
% back using the mask parameter.
% 
%   Inputs: 
%           im1, im2: The two images to stitch together. Images are assumed 
%               to be RGB images.
%           T_im2: The transformation to apply to im2.
%           mask: The mask computed so far from previous pairwise
%               stitchings. If not available, calculated on the fly by the
%               code.
%   Outputs:
%           stitched_image: The stitched image.
%           stitched_mask: The mask surrounding the result of the stitched
%               image. Will be useful for subsequent stitchings. In our
%               project, we don't care about subsequent stitchings and thus
%               we ignore this argument from caller methods.
%
%   Note: Function adapted out of a code found at "Panorama stitching in
%       MATLAB", publically available at: 
%       http://tobw.net/index.php?cat_id=2&project=Panorama+Stitching+Demo+in+Matlab

% Satisfy requirement for all images to be RGB.
if length(size(im1)) < 3
    im1 = repmat(im1, [1 1 3]);
end
if length(size(im2)) < 3
    im2 = repmat(im2, [1 1 3]);
end

% init masks
mask_im2 = uint8(ones(size(im2,1),size(im2,2)));
if nargin < 4
    mask_im1 = uint8(ones(size(im1, 1), size(im1, 2)));
else
    mask_im1 = mask;
end

% Transform image 2 so it fits on image 1
T_im2 = maketform('projective', [T_im2 ; [0 0 1]]');
[im2, XDATA, YDATA] = imtransform(im2, T_im2);
mask_im2 = imtransform(mask_im2, T_im2); % Do the same for the mask.

% stitched image bounds
W=max( [size(im1,2) size(im1,2)-XDATA(1) size(im2,2) size(im2,2)+XDATA(1)] );
H=max( [size(im1,1) size(im1,1)-YDATA(1) size(im2,1) size(im2,1)+YDATA(1)] );

% Align image 1 bounds
im1_X = eye(3);
if XDATA(1) < 0, im1_X(3,1)= -XDATA(1); end % Translation in the x direction
if YDATA(1) < 0, im1_X(3,2)= -YDATA(1); end % Translation in the y direction.
T_im1 = maketform('affine',im1_X); % This will now be a translation matrix, because of the way maketform assumes the matrix be formed!

[im1, XDATA2, YDATA2] = imtransform(im1, T_im1, 'XData', [1 W], 'YData', [1 H]);
mask_im1 = imtransform(mask_im1, T_im1, 'XData', [1 W], 'YData', [1 H]);

% Align image 2 bounds 
im2_X = eye(3);
if XDATA(1) > 0, im2_X(3,1)= XDATA(1); end
if YDATA(1) > 0, im2_X(3,2)= YDATA(1); end
T_im2 = maketform('affine',im2_X);

[im2, XDATA, YDATA] = imtransform(im2, T_im2, 'XData', [1 W], 'YData', [1 H]);
mask_im2 = imtransform(mask_im2, T_im2, 'XData', [1 W], 'YData', [1 H]);

% Size check
if (size(im1,1) ~= size(im2,1)) || (size(im1,2) ~= size(im2,2))
    H = max( size(im1,1), size(im2,1) );
    W = max( size(im1,2), size(im2,2) );
    im1(H,W,:)=0;
    im2(H,W,:)=0;
    mask_im1(H,W)=0;
    mask_im2(H,W)=0;
end

% Combine both images
n_layers = max(max(mask_im1));
im1part = uint16(mask_im1 > (n_layers * mask_im2));
im2part = uint16(mask_im2 > mask_im1);

combpart = uint16(repmat(mask_im1 .* mask_im2,[1 1 3]));
combmask = uint16(combpart > 0);

stitched_image = repmat(im1part,[1 1 3]) .* uint16(im1) + repmat(im2part,[1 1 3]) .* uint16(im2);
stitched_image =  stitched_image + ( combpart .* uint16(im1) + combmask .* uint16(im2) ) ./ (combpart + uint16(ones(size(combpart,1),size(combpart,2),3)));
%stitched_image =  stitched_image + ( combpart .* uint16(im1) + combmask .* uint16(im2) ) ./ 2;
stitched_image = uint8(stitched_image);
stitched_mask = mask_im1 + mask_im2;

%disp('Done.');
%toc(time);

end
