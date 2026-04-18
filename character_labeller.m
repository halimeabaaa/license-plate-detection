clc; clear; close all;

plateFolder = "cropped_plates";   % Plaka resimlerinin olduğu klasör
charRoot = "characters";          % Kaydedilecek karakter klasörü

files = dir(fullfile(plateFolder, "*.png"));

fprintf("Toplam %d plaka görüntüsü bulundu.\n", length(files));

for i = 1:length(files)

    imgPath = fullfile(plateFolder, files(i).name);
    
    % --- Plakayı oku ---
    plate = imread(imgPath);

    % --- Karakterleri segment et ---
    chars = segment_chars(plate);

    if isempty(chars)
        fprintf("⛔ Karakter bulunamadı → atlandı: %s\n", files(i).name);
        continue;
    end

    fprintf("\n=======================================\n");
    fprintf("Plaka: %s\n", files(i).name);
    fprintf("Bulunan karakter sayısı: %d\n", length(chars));
    fprintf("=======================================\n");

    for k = 1:length(chars)
        chr = chars{k};

        figure(1); 
        imshow(chr);
        title(sprintf("%s → Karakter %d", files(i).name, k), "FontSize", 14);

        % --- Kullanıcıdan etiket al ---
        label = upper(input("Bu karakter nedir? (0-9 / A-Z) (SKIP=atla): ", "s"));

        if isempty(label)
            fprintf("⚠ Etiket girilmedi → atlanıyor\n");
            continue;
        end

        if strcmp(label, "SKIP")
            fprintf("⚠ Kullanıcı atladı → kaydedilmeyecek\n");
            continue;
        end

        % --- Etiket klasörü ---
        saveFolder = fullfile(charRoot, label);
        if ~exist(saveFolder, "dir")
            mkdir(saveFolder);
        end

        % --- Kaydedilecek dosya adı ---
        saveName = sprintf("%s_%d.png", files(i).name(1:end-4), k);
        savePath = fullfile(saveFolder, saveName);

        imwrite(chr, savePath);
        fprintf("✔ Kaydedildi → %s\n", savePath);
    end

    close all;
end

fprintf("\n🎉 Tüm plaka karakterleri işlendi, dataset hazır!\n");
