%% function testEnd2End(image)
curdir = pwd
imagesdir = '/images2Cut/';
rootdir = strcat(curdir,imagesdir,'31_1.png')


img2cut = imread(rootdir);

if (size(img2cut,3) == 3)
    img2cut = rgb2gray(img2cut);
end

scales = [1.5:-0.1:0.5];
outputs = cell(11,4);

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
    OrigImage = outputs{id,3};
