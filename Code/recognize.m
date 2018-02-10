function [avgScore, word] = recognize(ratio, dNet);
%% Recognizing characters
curdir = pwd;
imagesdir = '/cutImages/';
rootdir = strcat(curdir,imagesdir);
dirdir = strcat(num2str(ratio), '/1');
subdir = [rootdir dirdir];

CutImages = imageDatastore(...
    subdir, ...
    'IncludeSubfolders',true, ...
    'LabelSource', 'foldernames');

%% recognizing
scalez = strcat('Recognizing with scale of (',  num2str(ratio), ')\n');
fprintf(scalez);
[CNNlabel, CNNscore] = classify(dNet, CutImages);

totScore = 0;
word = '';
for n = 1 : size(CNNscore,1)
    totScore =  totScore + max(CNNscore(n,:));
    word = strcat(word , char(CNNlabel(n)));
end

avgScore = totScore/size(CNNscore,1);



