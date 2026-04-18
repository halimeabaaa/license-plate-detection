clc; clear; close all;

plateFolder = "cropped_plates";
outputFolder = "dataset_chars";

if ~exist(outputFolder, "dir")
    mkdir(outputFolder);
end

files = dir(fullfile(plateFolder, "*.png"));

fprintf("Toplam %d plaka görüntüsü bulundu.\n", length(files));

for i = 1:length(files)
    
    imgPath = fullfile(files(i).folder, files(i).name);
    plate = imread(imgPath);

    chars = segment_chars(plate);
    if length(chars) < 2
        fprintf("⚠ Segmentasyon başarısız → atlandı: %s\n", files(i).name);
        continue;
    end


    fprintf("\n=== %s için karakter etiketleme ===\n", files(i).name);

    for k = 1:length(chars)

        figure(1); clf;
        imshow(chars{k});
        title(sprintf("%s → Karakter %d", files(i).name, k));

        label = upper(input("Bu karakter nedir? (0-9/A-Z): ", "s"));

        if isempty(label)
            disp("❗ Atlandı (etiket girilmedi)");
            continue;
        end

        classFolder = fullfile(outputFolder, label);
        if ~exist(classFolder, "dir")
            mkdir(classFolder);
        end

        saveName = sprintf("%s_%d.png", files(i).name(1:end-4), k);
        imwrite(chars{k}, fullfile(classFolder, saveName));

        fprintf("✔ Kaydedildi → %s/%s\n", label, saveName);
    end
end

fprintf("\n🎉 Dataset oluşturma tamamlandı!\n");
