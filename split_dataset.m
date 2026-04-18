clc; clear; close all;

srcFolder = "characters";
trainFolder = "train";
testFolder  = "test";

trainRatio = 0.8;

% Karakter klasörlerini bul
labels = dir(srcFolder);
labels = labels([labels.isdir] & ~startsWith({labels.name}, '.') & ...
               ~strcmp({labels.name}, 'train') & ...
               ~strcmp({labels.name}, 'test'));

fprintf("Toplam %d karakter sınıfı bulundu.\n", length(labels));

for i = 1:length(labels)
    lbl = labels(i).name;
    srcLabelPath = fullfile(srcFolder, lbl);

    % Klasörleri oluştur
    trainLabelPath = fullfile(trainFolder, lbl);
    testLabelPath  = fullfile(testFolder, lbl);

    if ~exist(trainLabelPath, "dir"), mkdir(trainLabelPath); end
    if ~exist(testLabelPath, "dir"), mkdir(testLabelPath); end

    % Bu karakter klasöründeki tüm görüntüleri al
    imgs = dir(fullfile(srcLabelPath, "*.png"));
    n = length(imgs);

    % Random karıştırma
    idx = randperm(n);

    % %80 train, %20 test
    nTrain = round(trainRatio * n);
    trainIdx = idx(1:nTrain);
    testIdx  = idx(nTrain+1:end);

    % Kopyalama
    for t = trainIdx
        copyfile(fullfile(srcLabelPath, imgs(t).name), trainLabelPath);
    end

    for t = testIdx
        copyfile(fullfile(srcLabelPath, imgs(t).name), testLabelPath);
    end

    fprintf("%s → %d train, %d test\n", lbl, numel(trainIdx), numel(testIdx));
end

fprintf("\n✔ Dataset train/test olarak ayrıldı.\n");
