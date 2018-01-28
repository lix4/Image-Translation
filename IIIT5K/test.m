load("testdata.mat");
load("testCharBound.mat");
% load("traindata.mat");
% load("trainCharBound.mat");

%%
k = 10
testCharBound(k);
imshow(imread(testCharBound(k).ImgName));

%%
xData = {};
yData = {};
for k = 1:size(traindata, 2)
    name = traindata(k).ImgName
    img = imread(name);
    gray_img = img;
    if (size(img, 3) > 1)
        gray_img = rgb2gray(img);
    end
    gray_img = imresize(gray_img, [32, 32]);
    xData = [xTest, gray_img];
    yData = [yTest, traindata(k).GroundTruth];
end

%%
save('./xTest.mat', 'xTest');
save('./yTest.mat', 'yTest');
% save('./xTrain.mat', 'xTrain');
% save('./yTrain.mat', 'yTrain');

