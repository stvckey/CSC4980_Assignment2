close all
clear all

GSUDir1 = fullfile("Image Stitching/stitch 2/");
GSUScene1 = imageDatastore(GSUDir1);

montage(GSUScene1.Files);

I = readimage(GSUScene1,1);


grayImage =  im2gray(I);
points = detectORBFeatures(grayImage);
[features, points] = extractFeatures(grayImage,points);


numImages = numel(GSUScene1.Files);
tforms(numImages) = projtform2d;


imageSize = zeros(numImages,2);


for n = 2:numImages
    pointsPrevious = points;
    featuresPrevious = features;

    
    I = readimage(GSUScene1, n);

    
    grayImage = im2gray(I);

     
    imageSize(n,:) = size(grayImage);

    
    points = detectORBFeatures(grayImage);    
    [features, points] = extractFeatures(grayImage, points);
  
    
    indexPairs = matchFeatures(features, featuresPrevious, 'Unique', true);
       
    matchedPoints = points(indexPairs(:,1), :);
    matchedPointsPrev = pointsPrevious(indexPairs(:,2), :);        
    
    
    tforms(n) = estgeotform2d(matchedPoints, matchedPointsPrev,...
        'projective', 'Confidence', 99.9, 'MaxNumTrials', 2000);
    
    .
    tforms(n).A = tforms(n-1).A * tforms(n).A; 
end 


for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);    
end

avgXLim = mean(xlim, 2);
[~,idx] = sort(avgXLim);
centerIdx = floor((numel(tforms)+1)/2);
centerImageIdx = idx(centerIdx);

Tinv = invert(tforms(centerImageIdx));
for i = 1:numel(tforms)    
    tforms(i).A = Tinv.A * tforms(i).A;
end

for i = 1:numel(tforms)           
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms(i), [1 imageSize(i,2)], [1 imageSize(i,1)]);
end

maxImageSize = max(imageSize);

 
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);


width  = round(xMax - xMin);
height = round(yMax - yMin);


panorama = zeros([height width 3], 'like', I);

blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');  


xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);


for i = 1:numImages
    
    I = readimage(GSUScene1, i);   
   

    warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
                  
   
    mask = imwarp(true(size(I,1),size(I,2)), tforms(i), 'OutputView', panoramaView);
    

    panorama = step(blender, panorama, warpedImage, mask);
end

figure
imshow(panorama)