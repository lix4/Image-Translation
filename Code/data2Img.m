for x = 3332 : 5000 
   %size(trainLabels,1)
   img = trainSet(1:32, 1:32, x);
   folderN = trainLabels(x);
   folderN = [int2str(folderN) '/'];
   name = ['images/test/' folderN int2str(x) '.png'];
   imwrite(img, name);
end    

for x = 11666 : 15000 
   %size(trainLabels,1)
   img = trainSet(1:32, 1:32, x);
   folderN = trainLabels(x);
   folderN = [int2str(folderN) '/'];
   name = ['images/test/' folderN int2str(x) '.png'];
   imwrite(img, name);
end    