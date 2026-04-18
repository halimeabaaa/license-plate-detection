function chars = segment_chars(plateImg)

    chars = {};

    % 1) Griye çevir
    if size(plateImg, 3) == 3
        gray = rgb2gray(plateImg);
    else
        gray = plateImg;
    end

    % 2) Ön işleme
    gray = imadjust(gray);
    gray = medfilt2(gray, [3 3]);

    % 3) İkili görüntü
    bw = imbinarize(gray, 'adaptive', ...
        'ForegroundPolarity', 'dark', ...
        'Sensitivity', 0.40);

    % Karakterler beyaz olsun
    bw = ~bw;

    % 4) Gürültü temizleme
    bw = bwareaopen(bw, 25);
    bw = imclearborder(bw);

    % Hafif morfolojik düzeltme
    bw = imopen(bw, strel('rectangle', [2 1]));
    bw = imclose(bw, strel('rectangle', [3 2]));

    % 5) Bileşen analizi
    cc = bwconncomp(bw);
    stats = regionprops(cc, 'BoundingBox', 'Area');

    if isempty(stats)
        return;
    end

    [H, W] = size(bw);

    boxes = [];
    tempChars = {};

    for k = 1:length(stats)
        bb = stats(k).BoundingBox;
        x = bb(1);
        y = bb(2);
        w = bb(3);
        h = bb(4);
        area = stats(k).Area;

        aspectRatio = w / h;
        heightRatio = h / H;
        widthRatio  = w / W;

        % --- Genel filtreler ---
        if area < 30
            continue;
        end

        % Karakter yüksekliği plakanın anlamlı bir kısmını kaplamalı
        if heightRatio < 0.40 || heightRatio > 0.95
            continue;
        end

        % Aşırı dar veya aşırı geniş objeleri at
        if widthRatio < 0.015 || widthRatio > 0.22
            continue;
        end

        % En-boy oranı çok anormalse at
        if aspectRatio < 0.10 || aspectRatio > 1.10
            continue;
        end

        % Çok üstte/çok altta kalan gürültüleri ele
        if y < 1 || (y + h) > H
            continue;
        end

        % Sol mavi TR alanındaki dar gürültüleri ele
        % ama ilk gerçek rakamı kaybetmemek için agresif davranma
        if x < 0.10 * W && w < 0.08 * W
            continue;
        end

        chr = imcrop(bw, bb);

        % Hafif kenarlık ekle
        chr = padarray(chr, [3 3], 0, 'both');

        % CNN giriş boyutu
        chr = imresize(chr, [42 24]);
        chr = uint8(chr) * 255;

        tempChars{end+1} = chr; %#ok<AGROW>
        boxes(end+1, :) = bb; %#ok<AGROW>
    end

    if isempty(boxes)
        return;
    end

    % 6) Soldan sağa sırala
    [~, idx] = sort(boxes(:,1));
    boxes = boxes(idx, :);
    tempChars = tempChars(idx);

    % 7) Çok yakın/çakışan kutularda tekrarları azalt
    keep = true(1, size(boxes,1));

    for i = 2:size(boxes,1)
        prev = boxes(i-1,:);
        curr = boxes(i,:);

        prevCenter = prev(1) + prev(3)/2;
        currCenter = curr(1) + curr(3)/2;

        % Merkezler aşırı yakınsa küçük olanı ele
        if abs(currCenter - prevCenter) < 0.04 * W
            prevArea = prev(3) * prev(4);
            currArea = curr(3) * curr(4);

            if currArea < prevArea
                keep(i) = false;
            else
                keep(i-1) = false;
            end
        end
    end

    tempChars = tempChars(keep);
    boxes = boxes(keep,:);

    % 8) Çok fazla karakter varsa yine soldan sağa en mantıklı 8 taneyi koru
    % Türk plakaları 7 veya 8 karakterli olduğu için
    if numel(tempChars) > 8
        tempChars = tempChars(end-7:end);
    end

    chars = tempChars;
end