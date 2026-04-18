classdef PlakaTanimaSistemi < handle
    properties
        UIFigure
        BackgroundImage

        % Paneller
        HeaderPanel
        LeftPanel
        RightTopPanel
        RightBottomPanel
        FooterPanel

        % Görsel alanları
        VehicleAxes
        PlateAxes

        % Etiketler
        TitleLabel
        SubtitleLabel
        LeftTitleLabel
        RightTopTitleLabel
        RightBottomTitleLabel
        FooterLabel

        RawPlateLabel
        FinalPlateLabel
        ConfidenceLabel
        StatusLabel

        % Butonlar
        LoadButton
        ResetButton

        % Model
        CnnNet

        % Dosya yolları
        PythonCmd = "C:\Users\halim\yolo_matlab_env\Scripts\python.exe"
        YoloScript
        YoloWeights
    end

    methods
        function obj = PlakaTanimaSistemi()
            obj.YoloScript = fullfile(pwd, "detect_plate.py");
            obj.YoloWeights = fullfile(pwd, "best.pt");

            if ~isfile("character_cnn.mat")
                errordlg("character_cnn.mat bulunamadı.");
                return;
            end

            if ~isfile(obj.YoloWeights)
                errordlg("best.pt bulunamadı.");
                return;
            end

            if ~isfile(obj.YoloScript)
                errordlg("detect_plate.py bulunamadı.");
                return;
            end

            data = load("character_cnn.mat");
            obj.CnnNet = data.net;

            obj.createUI();
            obj.resetUI();
        end

        function createUI(obj)
            % Renk paleti
            cBg         = [0.020 0.040 0.085];
            cHeader     = [0.055 0.095 0.175];
            cPanel      = [0.050 0.085 0.150];
            cPanelAlt   = [0.060 0.095 0.165];
            cInner      = [0.015 0.035 0.075];
            cText       = [0.935 0.970 1.000];
            cSub        = [0.700 0.840 0.965];
            cCyan       = [0.360 0.790 1.000];
            cGold       = [0.980 0.800 0.560];

            % Buton renkleri daha uyumlu hale getirildi
            cLoadBtn    = [0.14 0.38 0.78];
            cResetBtn   = [0.55 0.16 0.20];

            cSuccessBg   = [0.070 0.220 0.160];
            cSuccessText = [0.520 1.000 0.760];

            cInfoBg     = [0.025 0.060 0.115];
            cWarnBg     = [0.280 0.210 0.070];
            cWarnText   = [1.000 0.920 0.580];
            cErrorBg    = [0.320 0.090 0.120];
            cErrorText  = [1.000 0.780 0.780];
            cFooter     = [0.040 0.070 0.125];

            obj.UIFigure = uifigure( ...
                'Name', 'Plaka Tanıma Sistemi', ...
                'Position', [35 15 1500 890], ...
                'Color', cBg);

            % Arka plan görseli
            bgPath = fullfile(pwd, "arka_plan.png");
            if isfile(bgPath)
                obj.BackgroundImage = uiimage(obj.UIFigure, ...
                    'ImageSource', bgPath, ...
                    'Position', [0 0 1500 890], ...
                    'ScaleMethod', 'fill');
            else
                obj.BackgroundImage = [];
            end

            % Başlık paneli
            obj.HeaderPanel = uipanel(obj.UIFigure, ...
                'Position', [45 785 1400 72], ...
                'BackgroundColor', cHeader, ...
                'BorderType', 'line', ...
                'HighlightColor', cCyan);

            obj.TitleLabel = uilabel(obj.HeaderPanel, ...
                'Text', 'PLAKA TANIMA SİSTEMİ', ...
                'FontSize', 26, ...
                'FontWeight', 'bold', ...
                'FontColor', [0.72 1.00 0.88], ...
                'HorizontalAlignment', 'center', ...
                'Position', [290 20 820 32]);

            obj.SubtitleLabel = uilabel(obj.HeaderPanel, ...
                'Text', 'YOLOv8 + CNN ile plaka algılama, karakter ayırma ve akıllı doğrulama', ...
                'FontSize', 12, ...
                'FontColor', cSub, ...
                'HorizontalAlignment', 'center', ...
                'Position', [390 4 620 18]);

            % Sol panel
            obj.LeftPanel = uipanel(obj.UIFigure, ...
                'Position', [45 180 690 560], ...
                'BackgroundColor', cPanel, ...
                'BorderType', 'line', ...
                'HighlightColor', cCyan);

            obj.LeftTitleLabel = uilabel(obj.LeftPanel, ...
                'Text', 'ARAÇ GÖRÜNTÜSÜ', ...
                'FontSize', 19, ...
                'FontWeight', 'bold', ...
                'FontColor', cText, ...
                'HorizontalAlignment', 'center', ...
                'Position', [220 515 250 24]);

            obj.VehicleAxes = uiaxes(obj.LeftPanel, ...
                'Position', [48 118 590 370], ...
                'Color', cInner, ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'XColor', cCyan, ...
                'YColor', cCyan);
            title(obj.VehicleAxes, 'Araç Görüntüsü', ...
                'Color', cText, 'FontSize', 14, 'FontWeight', 'bold');

            obj.LoadButton = uibutton(obj.LeftPanel, 'push', ...
                'Text', '📤  Resim Yükle ve Oku', ...
                'FontSize', 15, ...
                'FontWeight', 'bold', ...
                'FontColor', [1 1 1], ...
                'BackgroundColor', cLoadBtn, ...
                'Position', [160 38 220 48], ...
                'ButtonPushedFcn', @(~,~) obj.processImage());

            obj.ResetButton = uibutton(obj.LeftPanel, 'push', ...
                'Text', '🗑️ Temizle', ...
                'FontSize', 15, ...
                'FontWeight', 'bold', ...
                'FontColor', [1 1 1], ...
                'BackgroundColor', cResetBtn, ...
                'Position', [410 38 160 48], ...
                'ButtonPushedFcn', @(~,~) obj.resetUI());

            % Sağ üst panel
            obj.RightTopPanel = uipanel(obj.UIFigure, ...
                'Position', [785 500 660 240], ...
                'BackgroundColor', cPanelAlt, ...
                'BorderType', 'line', ...
                'HighlightColor', cGold);

            obj.RightTopTitleLabel = uilabel(obj.RightTopPanel, ...
                'Text', 'TESPİT EDİLEN PLAKA', ...
                'FontSize', 19, ...
                'FontWeight', 'bold', ...
                'FontColor', cText, ...
                'HorizontalAlignment', 'center', ...
                'Position', [210 198 240 24]);

            obj.PlateAxes = uiaxes(obj.RightTopPanel, ...
                'Position', [55 40 550 130], ...
                'Color', [0.100 0.110 0.135], ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'XColor', cGold, ...
                'YColor', cGold);
            title(obj.PlateAxes, 'Tespit Edilen Plaka', ...
                'Color', cText, 'FontSize', 14, 'FontWeight', 'bold');

            % Sağ alt panel
            obj.RightBottomPanel = uipanel(obj.UIFigure, ...
                'Position', [785 180 660 285], ...
                'BackgroundColor', cPanel, ...
                'BorderType', 'line', ...
                'HighlightColor', cCyan);

            obj.RightBottomTitleLabel = uilabel(obj.RightBottomPanel, ...
                'Text', 'SONUÇ PANELİ', ...
                'FontSize', 20, ...
                'FontWeight', 'bold', ...
                'FontColor', cText, ...
                'HorizontalAlignment', 'center', ...
                'Position', [220 238 220 26]);

            obj.RawPlateLabel = uilabel(obj.RightBottomPanel, ...
                'Text', 'Ham Okuma: ---', ...
                'FontSize', 16, ...
                'FontColor', cText, ...
                'BackgroundColor', cInfoBg, ...
                'HorizontalAlignment', 'left', ...
                'Position', [30 185 600 34]);

            obj.FinalPlateLabel = uilabel(obj.RightBottomPanel, ...
                'Text', 'Nihai Plaka: ---', ...
                'FontSize', 27, ...
                'FontWeight', 'bold', ...
                'FontColor', cSuccessText, ...
                'BackgroundColor', cSuccessBg, ...
                'HorizontalAlignment', 'center', ...
                'Position', [30 126 600 46]);

            obj.ConfidenceLabel = uilabel(obj.RightBottomPanel, ...
                'Text', 'Tespit Güveni: ---', ...
                'FontSize', 16, ...
                'FontColor', cText, ...
                'BackgroundColor', cInfoBg, ...
                'HorizontalAlignment', 'left', ...
                'Position', [30 78 600 32]);

            obj.StatusLabel = uilabel(obj.RightBottomPanel, ...
                'Text', 'Durum: Hazır', ...
                'FontSize', 16, ...
                'FontWeight', 'bold', ...
                'FontColor', cWarnText, ...
                'BackgroundColor', cWarnBg, ...
                'HorizontalAlignment', 'center', ...
                'Position', [30 28 600 34]);

            % Footer
            obj.FooterPanel = uipanel(obj.UIFigure, ...
                'Position', [90 95 1320 45], ...
                'BackgroundColor', cFooter, ...
                'BorderType', 'line', ...
                'HighlightColor', [0.20 0.45 0.85]);

            obj.FooterLabel = uilabel(obj.FooterPanel, ...
                'Text', 'Sistem Durumu: Hazır', ...
                'FontSize', 13, ...
                'FontColor', cSub, ...
                'HorizontalAlignment', 'center', ...
                'Position', [300 11 720 22]);

            % Arka planın üstüne diz
            if ~isempty(obj.BackgroundImage)
                uistack(obj.BackgroundImage, 'bottom');
            end
            uistack(obj.HeaderPanel, 'top');
            uistack(obj.LeftPanel, 'top');
            uistack(obj.RightTopPanel, 'top');
            uistack(obj.RightBottomPanel, 'top');
            uistack(obj.FooterPanel, 'top');

            % Durum renkleri
            obj.StatusLabel.UserData.WarnBg = cWarnBg;
            obj.StatusLabel.UserData.WarnText = cWarnText;
            obj.StatusLabel.UserData.ErrorBg = cErrorBg;
            obj.StatusLabel.UserData.ErrorText = cErrorText;
            obj.StatusLabel.UserData.SuccessBg = cSuccessBg;
            obj.StatusLabel.UserData.SuccessText = cSuccessText;
        end

        function resetUI(obj)
            cla(obj.VehicleAxes);
            cla(obj.PlateAxes);

            title(obj.VehicleAxes, 'Araç Görüntüsü', ...
                'Color', [0.93 0.97 1.00], 'FontSize', 14, 'FontWeight', 'bold');
            title(obj.PlateAxes, 'Tespit Edilen Plaka', ...
                'Color', [0.93 0.97 1.00], 'FontSize', 14, 'FontWeight', 'bold');

            obj.RawPlateLabel.Text = "Ham Okuma: ---";
            obj.FinalPlateLabel.Text = "Nihai Plaka: ---";
            obj.ConfidenceLabel.Text = "Tespit Güveni: ---";
            obj.StatusLabel.Text = "Durum: Hazır";
            obj.StatusLabel.BackgroundColor = obj.StatusLabel.UserData.WarnBg;
            obj.StatusLabel.FontColor = obj.StatusLabel.UserData.WarnText;
            obj.FooterLabel.Text = "Sistem Durumu: Hazır";
        end

        function processImage(obj)
            [file, path] = uigetfile({'*.jpg;*.jpeg;*.png', 'Resim Dosyaları'});
            if isequal(file,0)
                return;
            end

            imgPath = fullfile(path, file);
            img = imread(imgPath);

            imshow(img, 'Parent', obj.VehicleAxes);
            cla(obj.PlateAxes);

            obj.RawPlateLabel.Text = "Ham Okuma: ---";
            obj.FinalPlateLabel.Text = "Nihai Plaka: ---";
            obj.ConfidenceLabel.Text = "Tespit Güveni: ---";
            obj.StatusLabel.Text = "Durum: Plaka tespit ediliyor...";
            obj.StatusLabel.BackgroundColor = obj.StatusLabel.UserData.WarnBg;
            obj.StatusLabel.FontColor = obj.StatusLabel.UserData.WarnText;
            obj.FooterLabel.Text = "Sistem Durumu: YOLO ile plaka aranıyor...";
            drawnow;

            try
                [plateImg, bbox, conf] = obj.detectPlate(imgPath, img);

                if isempty(plateImg)
                    obj.StatusLabel.Text = "Durum: Plaka bulunamadı.";
                    obj.StatusLabel.BackgroundColor = obj.StatusLabel.UserData.ErrorBg;
                    obj.StatusLabel.FontColor = obj.StatusLabel.UserData.ErrorText;
                    obj.FinalPlateLabel.Text = "Nihai Plaka: TESPİT EDİLEMEDİ";
                    obj.FooterLabel.Text = "Sistem Durumu: Plaka tespiti başarısız";
                    return;
                end

                imshow(img, 'Parent', obj.VehicleAxes);
                hold(obj.VehicleAxes, 'on');
                rectangle(obj.VehicleAxes, ...
                    'Position', [bbox(1), bbox(2), bbox(3), bbox(4)], ...
                    'EdgeColor', [0.22 1.00 0.70], ...
                    'LineWidth', 2.5);
                text(obj.VehicleAxes, bbox(1), max(1,bbox(2)-12), ...
                    sprintf('Plate %.2f', conf), ...
                    'Color', [1 1 0], ...
                    'FontSize', 12, ...
                    'FontWeight', 'bold');
                hold(obj.VehicleAxes, 'off');

                imshow(plateImg, 'Parent', obj.PlateAxes);
                obj.ConfidenceLabel.Text = "Tespit Güveni: " + sprintf("%.2f", conf);

                obj.StatusLabel.Text = "Durum: Karakterler okunuyor...";
                obj.StatusLabel.BackgroundColor = obj.StatusLabel.UserData.WarnBg;
                obj.StatusLabel.FontColor = obj.StatusLabel.UserData.WarnText;
                obj.FooterLabel.Text = "Sistem Durumu: Karakter segmentasyonu ve CNN sınıflandırması çalışıyor...";
                drawnow;

                chars = segment_chars(plateImg);

                if isempty(chars)
                    obj.StatusLabel.Text = "Durum: Karakter segmentasyonu başarısız.";
                    obj.StatusLabel.BackgroundColor = obj.StatusLabel.UserData.ErrorBg;
                    obj.StatusLabel.FontColor = obj.StatusLabel.UserData.ErrorText;
                    obj.FinalPlateLabel.Text = "Nihai Plaka: KARAKTER BULUNAMADI";
                    obj.FooterLabel.Text = "Sistem Durumu: Segmentasyon başarısız";
                    return;
                end

                rawPlate = "";
                for k = 1:length(chars)
                    chr = chars{k};
                    if ~isa(chr, 'uint8')
                        chr = uint8(chr);
                    end
                    chr = imresize(chr, [42 24]);
                    chrRGB = cat(3, chr, chr, chr);
                    label = classify(obj.CnnNet, chrRGB);
                    rawPlate = rawPlate + string(label);
                end

                finalPlate = obj.normalizeTurkishPlate(rawPlate);

                obj.RawPlateLabel.Text = "Ham Okuma: " + rawPlate;
                obj.FinalPlateLabel.Text = "Nihai Plaka: " + finalPlate;
                obj.StatusLabel.Text = "Durum: Tamamlandı.";
                obj.StatusLabel.BackgroundColor = obj.StatusLabel.UserData.SuccessBg;
                obj.StatusLabel.FontColor = obj.StatusLabel.UserData.SuccessText;
                obj.FooterLabel.Text = "Sistem Durumu: Okuma tamamlandı | Nihai plaka üretildi";

            catch ME
                obj.StatusLabel.Text = "Durum: Hata oluştu.";
                obj.StatusLabel.BackgroundColor = obj.StatusLabel.UserData.ErrorBg;
                obj.StatusLabel.FontColor = obj.StatusLabel.UserData.ErrorText;
                obj.RawPlateLabel.Text = "Ham Okuma: ---";
                obj.FinalPlateLabel.Text = "Nihai Plaka: ---";
                obj.FooterLabel.Text = "Sistem Durumu: Beklenmeyen hata oluştu";
                errordlg(ME.message, "Hata");
            end
        end

        function [plateImg, bboxOut, confOut] = detectPlate(obj, imgPath, img)
            plateImg = [];
            bboxOut = [];
            confOut = [];

            cmd = sprintf('"%s" "%s" "%s" "%s"', ...
                obj.PythonCmd, obj.YoloScript, obj.YoloWeights, imgPath);

            [status, cmdout] = system(cmd);
            if status ~= 0
                error("Python/YOLO çalıştırılamadı. Komut çıktısı: %s", cmdout);
            end

            outText = strtrim(string(cmdout));
            if contains(outText, "NO_DETECTION")
                return;
            end

            lines = splitlines(outText);
            lines = strip(lines);
            lines = lines(lines ~= "");
            if isempty(lines)
                error("YOLO çıktısı boş döndü.");
            end

            jsonLine = lines(end);
            data = jsondecode(char(jsonLine));

            bbox = round(data.bbox);
            confOut = data.conf;

            x1 = max(1, bbox(1));
            y1 = max(1, bbox(2));
            x2 = min(size(img,2), bbox(3));
            y2 = min(size(img,1), bbox(4));

            if x2 <= x1 || y2 <= y1
                return;
            end

            plateImg = img(y1:y2, x1:x2, :);
            bboxOut = [x1, y1, x2-x1, y2-y1];
        end

        function finalPlate = normalizeTurkishPlate(obj, rawPlate)
            %#ok<INUSD>
            s = upper(char(rawPlate));
            s = regexprep(s, '[^A-Z0-9]', '');

            if isempty(s)
                finalPlate = "";
                return;
            end

            s = obj.fixLeadingCityCode(s);

            candidates = strings(0);
            for L = [8 7]
                if strlength(string(s)) >= L
                    for i = 1:(length(s)-L+1)
                        sub = string(s(i:i+L-1));
                        if obj.isValidTurkishPlate(sub)
                            candidates(end+1) = sub; %#ok<AGROW>
                        end
                    end
                end
            end

            if ~isempty(candidates)
                finalPlate = candidates(end);
                return;
            end

            if strlength(string(s)) > 8
                s = char(extractAfter(string(s), strlength(string(s)) - 8));
            end
            finalPlate = string(s);
        end

        function sOut = fixLeadingCityCode(obj, sIn)
            %#ok<INUSD>
            s = char(sIn);
            firstNonDigit = regexp(s, '[A-Z]', 'once');
            if isempty(firstNonDigit)
                sOut = s;
                return;
            end

            digitBlock = s(1:firstNonDigit-1);
            if isempty(digitBlock)
                sOut = s;
                return;
            end

            if length(digitBlock) == 2
                sOut = s;
                return;
            end

            if length(digitBlock) >= 3
                fixedDigits = digitBlock(end-1:end);
                sOut = [fixedDigits s(firstNonDigit:end)];
                return;
            end

            sOut = s;
        end

        function tf = isValidTurkishPlate(obj, plate)
            %#ok<INUSD>
            p = char(upper(plate));
            patterns = {
                '^\d{2}[A-Z]\d{4}$'
                '^\d{2}[A-Z]\d{5}$'
                '^\d{2}[A-Z]{2}\d{3}$'
                '^\d{2}[A-Z]{2}\d{4}$'
                '^\d{2}[A-Z]{3}\d{2}$'
                '^\d{2}[A-Z]{3}\d{3}$'
            };

            tf = false;
            for k = 1:length(patterns)
                if ~isempty(regexp(p, patterns{k}, 'once'))
                    tf = true;
                    return;
                end
            end
        end
    end
end