% Top-level script for ps4.

%%%%%%%%%%%%%%%%% Load appropriate pre-compiled maxflow libraries. %%%%%%%%%%%%%%
archstr=computer('arch');
if strcmp(archstr, 'glnxa64') == 1
    fprintf('Linux 64-bit detected.\n');
    addpath(genpath('./maxflow_linux_x86_64'));
elseif strcmp(archstr, 'win64') ==1
    fprintf('Windows 64-bit detected.\n');
    addpath(genpath('./maxflow_win_x86_64'));
else
    error('Unfortunately, we haven''t compiled or tested the code on platforms other than 64-bit Linux or Windows.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Stereogram images %%%%%%%%%%%%%%%%%%%%%%%%%

L = double(imread('../images/I1L.jpg'));
R = double(imread('../images/I1R.jpg'));
fprintf('Stereogram images loaded.\n');
D=stereo(L, R);
fprintf('Stereo matching completed. Visualizing disparity map:\n');
figure; imagesc(D); colormap(gray); title('Disparity map for stereogram');

%%%%%%%%%%%%%%%%%%%%%%%%%% Tsokuba images %%%%%%%%%%%%%%%%%%%%%%%%%

L = double(imread('../images/T3bw.jpg'));
R = double(imread('../images/T4bw.jpg'));
D=stereo(L, R);
fprintf('Stereo matching completed. Visualizing disparity map:\n');
figure; imagesc(D); colormap(gray); title('Disparity map for Tsokuba images');