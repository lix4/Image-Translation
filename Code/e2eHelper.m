function [X, Y, img2cut, I] = e2eHelper (img2cut, ratio)
%% debugging
%{
curdir = pwd
imagesdir = '/images2Cut/';
rootdir = strcat(curdir,imagesdir,'31_1.png')


img2cut = imread(rootdir);

if (size(img2cut,3) == 3)
    img2cut = rgb2gray(img2cut);
end

ratio = .7;
%}


%% actual start
scalez = strcat('Detecting with scale of (',  num2str(ratio), ')\n');
fprintf(scalez);
dCNN = 'CNN/OldDetector.mat';
l = load(dCNN);
dNet = l.dNet;

num1  = size(img2cut,2);
numRat = int16(num1 * ratio);
img2cut = imresize(img2cut,[32 32+numRat]);

curdir = pwd;
imagesdir = '/cutImages/';
rootdir = strcat(curdir,imagesdir);
dirdir = strcat(num2str(ratio), '/1');
subdir = [rootdir dirdir];

for x = 1:2:numRat
    num = (x - 1)/2;
    if (num < 10)
        imgloc = strcat(subdir,'/0',int2str(num), '.png');
    else    
        imgloc = strcat(subdir,'/',int2str(num), '.png');
    end    
    cutimg = img2cut(:,x:31+x);
    imwrite(cutimg,imgloc);    
end

%% Detecting characters
imagesdir = '/cutImages/';
rootdir = strcat(curdir,imagesdir);
subdir = [rootdir dirdir];

CutImages = imageDatastore(...
    subdir, ...
    'IncludeSubfolders',true, ...
    'LabelSource', 'foldernames');


[CNNlabel, CNNscore] = classify(dNet, CutImages);



%% Scaling Score

score = CNNscore(:,1);
score = transpose(score);

[mask, I] = wtnms(score, 2);

%{
pScore = zeros(size(CNNscore,1),1);

for id = 1: 17
   numadded = 0;
   for subid = 1 : min(id,17) - 1
       pScore(id) =  pScore(id) + CNNscore(id - subid);
       numadded = numadded + 1;
   end
   for subid2 = 1 : 16
       pScore(id) = pScore(id) + CNNscore(subid2);
       numadded = numadded + 1;
   end
   pScore(id) = pScore(id)/numadded;
end    
    
for id = 17: size(CNNscore,1) - 16
       for subid2 = 1 : 16
       pScore(id) = pScore(id) + CNNscore(subid2);
       pScore(id) = pScore(id) + CNNscore(id - subid2);
       end
   pScore(id) = pScore(id)/32.0;
end

for id = size(CNNscore,1) - 17 : size(CNNscore,1) 
   numadded = 0;
   for subid = 1 : min(size(CNNscore,1) - id,17) - 1
       pScore(id) =  pScore(id) + CNNscore(subid);
       numadded = numadded + 1;
   end
   for subid2 = 1 : 16
       pScore(id) = pScore(id) + CNNscore(id - subid2);
       numadded = numadded + 1;
   end
   pScore(id) = pScore(id)/numadded;
end
%}

%% Plotting
Y = 2*(score(1,:) - .5);
X = 0:size(Y,2)-1;

%%figure;
%%subplot(2,1,1), plot(X,Y);
%%subplot(2,1,2), imshow(img2cut);



%% Img Locs
%{
for id = 1 : size(I,2)
    loc = (2*I(id)-1);
    cutimg = img2cut(:,loc:31+loc);
    figure;
    imshow(cutimg);
end    
imtool(img2cut);
%}

%% Clean Up
myFolder = strcat(pwd,'\cutImages\',num2str(ratio),'\1');
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
fprintf(1, 'Now deleting files in %s\n', myFolder);
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.png'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for k = 1 : length(theFiles)
  baseFileName = theFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName);
  %fprintf(1, 'Now deleting %s\n', fullFileName);
  delete(fullFileName);
end