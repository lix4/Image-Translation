function e2eHelper (img2cut, ratio)
scalez = strcat('Reading with scale of (',  num2str(ratio), ')\n');
fprintf(scalez);
dCNN = 'CNN/OldDetector.mat';
l = load(dCNN);
dNet = l.dNet;

num1  = size(img2cut,2);
numRat = int16(num1 * ratio);
img2cut = imresize(img2cut,[32,32+numRat]);

curdir = pwd;
imagesdir = '/cutImages/';
rootdir = strcat(curdir,imagesdir);
dirdir = strcat(num2str(ratio), '/1');
subdir = [rootdir dirdir];

for x = 1:numRat
    imgloc = strcat(subdir,'/',int2str(x), '.png');
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


%% Plotting
Y = 2*(pScore(:,1) - .5);
X = 0:size(Y,1)-1;
figure
plot(X,Y)
figure
imshow(img2cut);

%% Clean Up
myFolder = strcat('C:\Users\schaffqg\Documents\GitHub\Image-Translation\Code\cutImages\',num2str(ratio),'\1');
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