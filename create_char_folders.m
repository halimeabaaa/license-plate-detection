rootFolder = "characters";

if ~exist(rootFolder, "dir")
    mkdir(rootFolder)
end

letters = ['A':'Z' '0':'9'];

for i = 1:length(letters)
    folderName = fullfile(rootFolder, letters(i));
    if ~exist(folderName, "dir")
        mkdir(folderName)
    end
end

disp("✔ Karakter klasörleri oluşturuldu!");
