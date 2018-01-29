%%Initializing DataSets
curdir = pwd

%rootdir = './images/';
imagesdir = '/images/';
rootdir = strcat(curdir,imagesdir)
subdir = [rootdir 'train'];

fprintf('Reading training images\n');

trainDImages = imageDatastore(...
    subdir, ...
    'IncludeSubfolders',true, ...
    'LabelSource', 'foldernames');

subdir = [rootdir 'validate'];


validateDImages = imageDatastore(...
    subdir, ...
    'IncludeSubfolders',true, ...
    'LabelSource', 'foldernames');

subdir = [rootdir 'test'];

testDImages = imageDatastore(...
    subdir, ...
    'IncludeSubfolders',true, ...
    'LabelSource', 'foldernames');

%dataSetcode
%{
subdir = [rootdir 'smallDetectorDataSet.mat']
l = load(subdir);
cvLabels = l.cvLabels;
cvSet = l.cvSet;
trainLabels = l.trainLabels;
trainSet = l.trainSet;
%}

%% Training CNN Detector
dCNN = 'CNN/Detector.mat';
fprintf('Training Detector\n');
if exist(dCNN) == 2
    l = load(dCNN);
    dNet = l.dNet;
else   
    layers = [
        imageInputLayer([32 32 1], 'Name', 'data')

        convolution2dLayer(8,96, 'Name','conv1')
        reluLayer('Name' , 'relu1')

        averagePooling2dLayer(5, 'Name','pool1')

        convolution2dLayer(8,256, 'Name','conv2')
        reluLayer('Name' , 'relu2')

        averagePooling2dLayer(2, 'Name','pool2')

        fullyConnectedLayer(2, 'Name','fcl1')
        softmaxLayer('Name' , 'softmax')
        classificationLayer('Name' , 'output')];

    miniBatchSize = 10;
    numIterationsPerEpoch = floor(numel(trainDImages.Labels)/miniBatchSize);
    options = trainingOptions('sgdm',...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',4,...
    'InitialLearnRate',1e-4,...
    'Verbose',false,...
    'Plots','training-progress',...
    'ValidationData',validateDImages,...
    'ValidationFrequency',numIterationsPerEpoch);

    dNet = trainNetwork(trainDImages,layers,options);

    save(dCNN,'dNet','options')
end
%% Looking at accuracy of Detector CNN
    fprintf('Looking at detector accuracy\n');
    predictedLabels = classify(dNet,testDImages);
    valLabels = testDImages.Labels;
    accuracy = sum(predictedLabels == valLabels)/numel(valLabels)

%% Initializing CNN REcog
curdir = pwd;
fprintf('Reading recognizor images\n');
imagesdir = '/rImages/';
rootdir = strcat(curdir,imagesdir);
subdir = [rootdir 'train'];

trainRImages = imageDatastore(...
    subdir, ...
    'IncludeSubfolders',true, ...
    'LabelSource', 'foldernames');

subdir = [rootdir 'test'];

testRImages = imageDatastore(...
    subdir, ...
    'IncludeSubfolders',true, ...
    'LabelSource', 'foldernames');

%% Finding bad images
%{
T = readall(trainRImages); 
for i =  1: 4798
    si = size(T{i});
    si1 = si(1);
    si2 = si(2);
    if (si1 == 32 & si2 == 32)
        
    else
    name = [int2str(si1) ' ' int2str(si1) ' ' int2str(i) '\n'];      
    fprintf(name);    
    end    
end
%}

%% Training CNN Recoqnizer
rCNN = 'CNN/Recognizer.mat';
fprintf('Training Recognizer\n');
if exist(rCNN) == 2
    l = load(rCNN);
    rNet = l.rNet;
else   
    layers = [
        imageInputLayer([32 32 1], 'Name', 'data')

        convolution2dLayer(8,115, 'Name','conv1')
        reluLayer('Name' , 'relu1')

        averagePooling2dLayer(5, 'Name','pool1')

        convolution2dLayer(8,720, 'Name','conv2')
        reluLayer('Name' , 'relu2')

        averagePooling2dLayer(2, 'Name','pool2')

        fullyConnectedLayer(62, 'Name','fcl1')
        softmaxLayer('Name' , 'softmax')
        classificationLayer('Name' , 'output')];

    miniBatchSize = 10;
    numIterationsPerEpoch = floor(numel(trainRImages.Labels)/miniBatchSize);
    options = trainingOptions('sgdm',...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',4,...
    'InitialLearnRate',1e-4,...
    'Verbose',false,...
    'Plots','training-progress',...
    'ValidationData',testRImages,...
    'ValidationFrequency',numIterationsPerEpoch);

    rNet = trainNetwork(trainRImages,layers,options);

    save(rCNN,'rNet','options')
end
%% Looking at accuracy of Recognizer CNN
    fprintf('Looking at recognizor accuracy\n');
    predictedLabels = classify(rNet,testRimages);
    valLabels = testRimages.Labels;
    accuracy = sum(predictedLabels == valLabels)/numel(valLabels)