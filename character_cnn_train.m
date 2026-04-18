clc; clear; close all;

% 1) Veri klasörleri
trainFolder = "train";
testFolder  = "test";

% 2) ImageDatastore oluştur
imdsTrain = imageDatastore(trainFolder, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

imdsTest = imageDatastore(testFolder, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

fprintf("Eğitim seti: %d görüntü\n", numel(imdsTrain.Files));
fprintf("Test seti: %d görüntü\n", numel(imdsTest.Files));

% 3) Resimleri CNN'e uygun boyuta getir
inputSize = [42 24];

augTrain = augmentedImageDatastore(inputSize, imdsTrain, ...
    'ColorPreprocessing','gray2rgb');

augTest = augmentedImageDatastore(inputSize, imdsTest, ...
    'ColorPreprocessing','gray2rgb');

% 4) CNN Mimarisi
layers = [
    imageInputLayer([42 24 3], "Name","input")

    convolution2dLayer(3, 32, "Padding","same")
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2, "Stride",2)

    convolution2dLayer(3, 64, "Padding","same")
    batchNormalizationLayer
    reluLayer

    fullyConnectedLayer(numel(categories(imdsTrain.Labels)))
    softmaxLayer
    classificationLayer
];

% 5) Eğitim ayarları
options = trainingOptions("adam", ...
    "MaxEpochs", 15, ...
    "MiniBatchSize", 128, ...
    "Shuffle", "every-epoch", ...
    "Verbose", true, ...
    "Plots","training-progress");

% 6) Model Eğitimi
net = trainNetwork(augTrain, layers, options);

% 7) Test
YPred = classify(net, augTest);
YTrue = imdsTest.Labels;

accuracy = mean(YPred == YTrue)*100;
fprintf("\n---------------------------\n");
fprintf("Test doğruluk: %.2f %%\n", accuracy);
fprintf("---------------------------\n");

% 8) Confusion Matrix
figure;
confusionchart(YTrue, YPred);
title("CNN Confusion Matrix");

% 9) Modeli kaydet
save("character_cnn.mat", "net");
disp("✔ Model kaydedildi: character_cnn.mat");
