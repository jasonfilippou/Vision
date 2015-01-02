% CANNY Run Canny edge detector with hysteresis on some example images.
% We will be using the following parameters which have been found to produce
% good results: sigma = 2, T1 = 15 and T2 = 2. T1 is the threshold for NMS,
% and T2 is the threshold for hysteresis.

Swan = imread('images/swanbw.jpg'); % Already grayscale
Coin = rgb2gray(imread('images/coins.png'));
Text = rgb2gray(imread('images/text.png'));
disp('Loaded images.');

figure('Position', [200, 300, 600, 300]);
subplot(1, 3, 1); imshow(Swan, []);
title('Swan');
subplot(1, 3, 2); imshow(Coin, []);
title('Coins');
subplot(1, 3, 3); imshow(Text, []);
title('Text');
% Setting a master title when subplots are involved is a pain...
% Solution taken from: https://sites.google.com/site/kittipat/matlabtechniques/howtoplotthemaintitletoafigurewithmanysubplots
axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 0.95, '\bf Original Images','HorizontalAlignment','center','VerticalAlignment', 'top', 'FontSize', 14);

disp('Running edge detection....');
SwanH = hysteresis(Swan, 2, 15, 2);
CoinH = hysteresis(Coin, 2, 15, 2);
TextH = hysteresis(Text, 2, 15, 2);
disp('Edge detection run. Visualizing results.');
figure('Position', [1000, 300, 600, 300]);
subplot(1, 3, 1); imshow(SwanH, []);
title('Swan');
subplot(1, 3, 2); imshow(CoinH, []);
title('Coins');
subplot(1, 3, 3); imshow(TextH, []);
title('Text');
ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 0.95, '\bf Edge Detection results','HorizontalAlignment','center','VerticalAlignment', 'top', 'FontSize', 14);
disp('Done. You may substitute the images used in this demo with more images in the "images" directory. Bye!');