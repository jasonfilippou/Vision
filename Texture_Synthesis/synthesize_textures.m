%% Synthesize three different texture for four different window sizes.

clear; clc;
% Bricks...
fprintf('Synthesizing bricks texture with a window size of 5....\n');
bricks5 = grow_image('input_textures/brickbw.jpg', 5);
fprintf('Synthesizing bricks texture with a window size of 11....\n');
bricks11 = grow_image('input_textures/brickbw.jpg', 11);
fprintf('Synthesizing bricks texture with a window size of 15....\n');
bricks15 = grow_image('input_textures/brickbw.jpg', 15);
fprintf('Synthesizing bricks texture with a window size of 23....\n');
bricks23 = grow_image('input_textures/brickbw.jpg', 23);
save('output_textures/bricks.mat');
clear;

% Rice...
fprintf('Synthesizing rice texture with a window size of 5....\n');
rice5 = grow_image('input_textures/rice.png', 5);
fprintf('Synthesizing rice texture with a window size of 11....\n');
rice11 = grow_image('input_textures/rice.png', 11);
fprintf('Synthesizing rice texture with a window size of 15....\n');
rice15 = grow_image('input_textures/rice.png', 15);
fprintf('Synthesizing rice texture with a window size of 23....\n');
rice23 = grow_image('input_textures/rice.png', 23);
save('output_textures/rice.mat');
clear;

% Text....
fprintf('Synthesizing text texture with a window size of 5....\n');
text5 = grow_image('input_textures/text.png', 5);
fprintf('Synthesizing text texture with a window size of 11....\n');
text11 = grow_image('input_textures/text.png', 11);
fprintf('Synthesizing text texture with a window size of 15....\n');
text15 = grow_image('input_textures/text.png', 15);
fprintf('Synthesizing text texture with a window size of 23....\n');
text23 = grow_image('input_textures/text.png', 23);
save('output_textures/text.mat');
clear;