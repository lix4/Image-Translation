img = imread('img053-00049.png');
%img = rgb2gray(img);
img = imresize(img, [32, 32])
imwrite(img, 'img053-00049.png');