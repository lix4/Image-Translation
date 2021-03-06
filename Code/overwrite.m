% function [r_img] = overwrite(img, word)

    %load dictionary
    % myDictionary = readtable('dictionary.xlsx', 'TextType', 'string');
    % row_name = myDictionary.raw == 'Nokia';
    % vars = {'translation'};
    % val = myDictionary(row_name, vars);
    % myDictionary({word}, :)
    img = OrigImage;
    word = 'world';
    word_keySet =   {'Calvin', 'PanJab', 'nokia', 'world'};
    word_valueSet = {'????', '??', '???', '??'};
    word_dictionary = containers.Map(word_keySet, word_valueSet);

    % fontsize_keySet = {'Nokia'};
    % fontsize_valueSet = {40};
    % fontsize_dictionary = containers.Map(fontsize_keySet, word_valueSet);

    % font_keySet = {};
    % pixel_valueSet = {};
    % font_conversion_dictionary = containers.Map(font_keySet, pixel_valueSet);

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
        numforegroundPixels = 9999;
        backgroundColor = means(1, :);
        foregroundColor = means(2, :);
        for d = 1:k
            num = numel(r(find(r == d)));
            if num > numbackgroundPixels
                numbackgroundPixels = num;
                backgroundColor = means(d, :);
                if d == 2
                    foregroundColor = means(1, :);
                else
                    foregroundColor = means(2, :);
                end
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
    [row col cha] = size(img);
    text_str = cell(1,1);
    text_str{1} = [word_dictionary(word)];
    r_position = row / 2;
    c_position = col / 2;
    position = [c_position r_position];
    foreground = uint8(foregroundColor(1, :) * 255);
    RGB = insertText(f_img, position, text_str,'BoxOpacity', 0, 'FontSize', 40, 'TextColor', foreground, 'Font', 'MS PMincho', 'AnchorPoint', 'Center');
    imshow(RGB);
%     r_img = RGB;
% end