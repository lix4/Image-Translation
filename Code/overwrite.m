clc
close all;
clear all;

img = imread('./6_8.png');
% use Kmeans to find background color
k = 2;
seed = 10; % or any fixed integer, for debugging. 
rand('state', seed);
means = rand(k,3); % creates a k-by-3 matrix of random numbers

iteration = 10;
for iter = 1:iteration
    double_img = im2double(img);
    [r] = kmean(k, means, double_img);
    [row col channel] = size(double_img);
    numbackgroundPixels = 1;
    backgroundColor = means(1, :);
    for d = 1:k
%         disp('------------------------------------------');
        num = numel(r(find(r == d)));
        if num > numbackgroundPixels
            numbackgroundPixels = num;
            backgroundColor = means(d, :);
        end
        if num == 0
            continue;
        end
        [a b] = find(r == d);
        sumR = 0;
        sumG = 0;
        sumB = 0;
        for count = 1:num
            sumR = sumR + double_img(a(count), b(count), 1);
            sumG = sumG + double_img(a(count), b(count), 2);
            sumB = sumB + double_img(a(count), b(count), 3);
        end
        means(d, 1) = sumR / num;
        means(d, 2) = sumG / num;
        means(d, 3) = sumB / num;
    end
end

for o = 1:row
    for p = 1:col
        double_img(o, p, 1) = backgroundColor(:, 1);
        double_img(o, p, 2) = backgroundColor(:, 2);
        double_img(o, p, 3) = backgroundColor(:, 3);
    end
end

f_img = im2uint8(double_img);
% imshow(f_img);
% insert text
text_str = cell(1,1);
text_str{1} = ['?????'];
position = [7 2]; 
RGB = insertText(f_img, position, text_str,'BoxOpacity', 0, 'FontSize', 15, 'TextColor', means(1, :), 'Font', 'MS PMincho');
imshow(RGB);