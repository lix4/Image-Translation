%%Initializing DataSets
curdir = pwd

%rootdir = './images/';
imagesdir = '/images/';
rootdir = strcat(curdir,imagesdir)
subdir = [rootdir 'train'];

trainImages = imageDatastore(...
    subdir, ...
    'IncludeSubfolders',true, ...
    'LabelSource', 'foldernames');

subdir = [rootdir 'validate'];


validateImages = imageDatastore(...
    subdir, ...
    'IncludeSubfolders',true, ...
    'LabelSource', 'foldernames');

subdir = [rootdir 'test'];

testImages = imageDatastore(...
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
    numIterationsPerEpoch = floor(numel(trainImages.Labels)/miniBatchSize);
    options = trainingOptions('sgdm',...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',4,...
    'InitialLearnRate',1e-4,...
    'Verbose',false,...
    'Plots','training-progress',...
    'ValidationData',validateImages,...
    'ValidationFrequency',numIterationsPerEpoch);

    dNet = trainNetwork(trainData,layers,options);

    save(dCNN,'dNet','options')
end
%% Looking at accuracy of Detector CNN
    predictedLabels = classify(dNet,valDigitData);
    valLabels = valDigitData.Labels;
    accuracy = sum(predictedLabels == valLabels)/numel(valLabels)
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

        fullyConnectedLayer(2, 'Name','fcl1')
        softmaxLayer('Name' , 'softmax')
        classificationLayer('Name' , 'output')];

    miniBatchSize = 10;
    numIterationsPerEpoch = floor(numel(trainImages.Labels)/miniBatchSize);
    options = trainingOptions('sgdm',...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',4,...
    'InitialLearnRate',1e-4,...
    'Verbose',false,...
    'Plots','training-progress',...
    'ValidationData',validateImages,...
    'ValidationFrequency',numIterationsPerEpoch);

    rNet = trainNetwork(trainImages,layers,options);

    save(rCNN,'rNet','options')
end
%% Looking at accuracy of Recognizer CNN
    predictedLabels = classify(rNet,valData);
    valLabels = valData.Labels;
    accuracy = sum(predictedLabels == valLabels)/numel(valLabels)