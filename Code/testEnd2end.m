%% function testEnd2End(image)
curdir = pwd
imagesdir = '/images2Cut/';
rootdir = strcat(curdir,imagesdir,'5190_1.png')


img2cut = imread(rootdir);

if (size(img2cut,3) == 3)
    img2cut = rgb2gray(img2cut);
end


%e2eHelper(img2cut,.5);
e2eHelper(img2cut,.75);
%e2eHelper(img2cut,1);
%e2eHelper(img2cut,1.5);
%e2eHelper(img2cut,2);


