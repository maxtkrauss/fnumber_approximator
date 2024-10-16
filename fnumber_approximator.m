clear;
clc;

% Prompt user to select a folder containing TIFF images
folder = uigetdir('', 'Select a folder containing TIFF images');
if folder == 0
   disp('User canceled folder selection');
   return;
end

fileList = dir(fullfile(folder, '*.tif'));
fileNames = {fileList.name};
avgIntensities = zeros(length(fileList), 1);

% Number of files
numFiles = length(fileList);

% Create a new figure
figure;

% Loop through all the TIFF files
for i = 1:numFiles
    filename = fullfile(folder, fileList(i).name);
    img = imread(filename);
    
    % Define the region of interest (ROI)
    roi = img(800:900, 1000:1400); 
    
    subplot(ceil(sqrt(numFiles)), ceil(sqrt(numFiles)), i);
    imshow(img, []);
    title(fileList(i).name, 'Interpreter', 'none');
   
    avgIntensities(i) = mean(roi(:));
end

intensityTable = table(fileNames', avgIntensities, 'VariableNames', {'FileName', 'AverageIntensity'});

sortedIntensityTable = sortrows(intensityTable, 'AverageIntensity', 'descend');

calculate_f_number(sortedIntensityTable, 1.4)

function fNumbers = calculate_f_number(intensityTable, fNumberFullyOpen)
    idxFullOpen = strcmp(intensityTable.FileName, '0.0.tif');
    intensityFullyOpen = intensityTable.AverageIntensity(idxFullOpen);

    fNumbers = zeros(height(intensityTable), 1);
    
    % Loop over all intensity readings and calculate f-number
    for i = 1:height(intensityTable)
        intensity = intensityTable.AverageIntensity(i);

        fNumbers(i) = fNumberFullyOpen * sqrt(intensityFullyOpen / intensity);
    end

    intensityTable.FNumber = fNumbers;

    disp(intensityTable);
end
