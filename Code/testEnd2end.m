feature('DefaultCharacterSet', 'UTF8')

%% function testEnd2End(image)
curdir = pwd
imagesdir = '/images2Cut/';
rootdir = strcat(curdir,imagesdir,'31_1.png');

img2cut = imread(rootdir);
orig = imread(rootdir);

if (size(img2cut,3) == 3)
    img2cut = rgb2gray(img2cut);
end

scales = [1.5:-0.1:0.5];
outputs = cell(11,5);

%% Running
for x = 1 : size(scales,2)
 [X, Y, img, I]  = e2eHelper(img2cut,scales(x));  
 outputs{x,1} = X;
 outputs{x,2} = Y;
 outputs{x,3} = img;
 outputs{x,4} = I;
end

%% Output
figure;
for x = 1:3
    
    subplot(2,3,x), plot(outputs{x,1},outputs{x,2})
    subplot(2,3,3+x), imshow(outputs{x,3})

end    

figure;
for x = 4:7
    
    subplot(2,4,x-3), plot(outputs{x,1},outputs{x,2})
    subplot(2,4,x+1), imshow(outputs{x,3})

end

figure;
for x = 8:11
    
    subplot(2,4,x-7), plot(outputs{x,1},outputs{x,2})
    subplot(2,4,x-3), imshow(outputs{x,3})

end 

%% Img Locs

%set up code
curdir = pwd;
imagesdir = '/cutImages/';
rootdir = strcat(curdir,imagesdir);
avgScores = zeros(11,1);
letters = cell(11,1);


fprintf('Loading Recognizer\n');
dCNN = 'CNN/Alex_gray.mat';
l = load(dCNN);
dNet = l.netTransfer;
fprintf('Loaded Recognizer\n');

%% putting into recognizer
for idx = 1 : size(scales,2)
    dirdir = strcat(num2str(scales(idx)), '/1');
    subdir = [rootdir dirdir];
    img2cut = outputs{idx,3};
    I = outputs{idx,4};
    for id = 1 : size(I,2)
        loc = (2*I(id)-1);
        if (id < 10)
            imgloc = strcat(subdir,'/0',int2str(id), '.png');
        else    
            imgloc = strcat(subdir,'/',int2str(id), '.png');
        end 
        cutimage = img2cut(:,loc:31+loc);
        cutimg = cat(3, cutimage, cutimage, cutimage);
        cutimg = imresize(cutimg, [227 227]);
        outputs{idx,5} = cutimg;
        imwrite(cutimg,imgloc);   
    end
    [avgScore , word] = recognize(scales(idx),dNet);
    avgScores(idx) = avgScore;
    letters{idx} = word;
end

%% Getting word
complete = 0;
while (complete == 0)
    maximum = max(avgScores);
    id = find(avgScores == maximum);
    word2Translate = letters{id};
    tOrF = isRealWord(word2Translate);
    if (tOrF == 1)
        complete = 1;
    else
        avgScores(id) = -1;
    end    
end    
    curScale = scales(id);
    OrigImage = outputs{id,5};
    
    %%
    img = orig;
    se = strel('square',5);
    opened_img = imopen(img(:, :, 1), se);
    mask = imbinarize(opened_img);
    imshow(mask);
    
    % calculate the bounding box in order to calculate font size
    bounding_box = regionprops(mask, 'BoundingBox');
    [b_row b_col] = size(bounding_box);
    g_height = 0;
    for a = 1:b_row
        row = bounding_box(a)
        g_height = g_height + row.BoundingBox(4);
    end
    g_height = g_height / b_row;
    
    % calculate general centroid of the whole text
    centroid = regionprops(mask, 'Centroid');
    [c_row c_col] = size(centroid);
    g_x = 0;
    g_y = 0;
    for k = 1:c_row
        row = centroid(k);
        x = row.Centroid(1);
        g_x = g_x + x;
        y = row.Centroid(2);
        g_y = g_y + y;
    end
    
    g_x = g_x / c_row;
    g_y = g_y / c_row;
    
    word = 'bank';
    word_keySet =   {'Calvin', 'PanJab', 'nokia', 'world','bank'};
    word_valueSet = {'????', '??', '???', '??', '??'};
    word_dictionary = containers.Map(word_keySet, word_valueSet);

%     trueGaussian= fspecial('gaussian', [5,5],3);
%     filtered_img = filter2(trueGaussian, img);
%     imtool(uint8(filtered_img));
    
    %%
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
    r_position = g_y;
    c_position = g_x;
    font_size = uint8(g_height);
    position = [c_position r_position];
    foreground = uint8(foregroundColor(1, :) * 255);
    RGB = insertText(f_img, position, text_str,'BoxOpacity', 0, 'FontSize', font_size, 'TextColor', foreground, 'Font', 'MS PMincho', 'AnchorPoint', 'Center');
    imshow(RGB);