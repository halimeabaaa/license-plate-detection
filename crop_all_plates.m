clc; clear; close all;

% === KLASÖRLER ==
imageFolder = "images";     % Araç resimlerinin olduğu klasör
labelFolder = "labels";     % YOLO txt dosyaları
outputFolder = "cropped_plates";

if ~exist(outputFolder, "dir")%outputfolder adında klasör var mı ~ yok anlamına geliyor
    mkdir(outputFolder);
end

% Resimleri oku (jpg veya png fark etmez)
files = dir(fullfile(imageFolder, "*.*"));
files = files(~[files.isdir]);   % klasörleri çıkar

fprintf("Toplam %d adet görüntü bulundu.\n", length(files));

for i = 1:length(files)

    [~, baseName, ext] = fileparts(files(i).name);

    % Uzantı görüntü değilse geç (PDF, txt vs olabilir)
    if ~ismember(lower(ext), {'.jpg', '.png', '.jpeg'})
        fprintf("➜ Atlaniyor (gorsel degil): %s\n", files(i).name);
        continue;
    end

    imgPath = fullfile(files(i).folder, files(i).name);
    txtPath = fullfile(labelFolder, baseName + ".txt");

    if ~isfile(txtPath)
        fprintf("⚠ TXT bulunamadi, atlaniyor: %s.txt\n", baseName);
        continue;
    end

    % --- 1. RESMI OKU ---
    img = imread(imgPath);
    [H, W, ~] = size(img);

    % --- 2. TXT OKU ---
    bboxNorm = read_yolo_bbox(txtPath);  
    % format: [x_center, y_center, w, h]

    % --- 3. YOLO'daki normalized koordinatları piksele çevir ---
    xC = bboxNorm(1) * W;
    yC = bboxNorm(2) * H;
    bw = bboxNorm(3) * W;
    bh = bboxNorm(4) * H;

    xmin = round(xC - bw/2);
    ymin = round(yC - bh/2);
    xmax = round(xC + bw/2);
    ymax = round(yC + bh/2);

    % Taşanları engelle
    xmin = max(1, xmin);
    ymin = max(1, ymin);
    xmax = min(W, xmax);
    ymax = min(H, ymax);

    % --- 4. PLAKAYI KES ---
    plateImg = img(ymin:ymax, xmin:xmax, :);
    if isempty(plateImg) || size(plateImg,1) < 10 || size(plateImg,2) < 30
            fprintf("⚠ Boş plaka geldi, atlanıyor: %s\n", baseName);
        continue;
    end
    % 1) Plaka çok ince ise ele
[h, w, ~] = size(plateImg);
if h < 25 || h > 250
    fprintf("⚠ İnce veya bozuk plaka atlandı: %s\n", baseName);
    continue;
end

% 2) En/Boy oranı anormal ise ele
ratio = w / h;
if ratio < 2 || ratio > 10
    fprintf("⚠ Oransız plaka atlandı: %s\n", baseName);
    continue;
end

% 3) Ortalama parlaklık çok düşük/yüksekse ele
meanVal = mean(plateImg(:));
if meanVal < 40 || meanVal > 230
    fprintf("⚠ Çok karanlık/aydınlık plaka atlandı: %s\n", baseName);
    continue;
end

% 4) Kenar (edge) yoğunluğu yoksa ele
edgeImg = edge(rgb2gray(plateImg), "sobel");
edgeCount = sum(edgeImg(:));

if edgeCount < 150
    fprintf("⚠ Kenar yok → plaka değil: %s\n", baseName);
    continue;
end


    % --- 5. Kaydet ---
    outPath = fullfile(outputFolder, baseName + ".png");
    imwrite(plateImg, outPath);

    fprintf("✔ Kaydedildi: %s\n", outPath);
end

disp("🎉 Tum plakalari kesme islemi basariyla tamamlandi!")
