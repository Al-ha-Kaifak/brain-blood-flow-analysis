%% DICOM Image Organization for Brain Blood Flow Analysis
% This script organizes CTA and CTP DICOM images for brain blood flow analysis.
% It creates a structured dataset where:
% - CTP images are organized by their spatial location (23 unique locations)
% - CTA images are filtered based on CTP locations and grouped in sets of four
% 
% Author: Yotam Gunders
% Last Modified: 26.11.2024



%% Define Folder Paths
% Set paths for CTA and CTP DICOM folders
ctaFolderPath = "C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\final final project\ANONJA72BI1FH Male 1956\ANONJA72BI1FH Male 1956 'AXIAL MIP F_0.7'";
ctpFolderPath = "C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\final final project\ANONJA72BI1FH Male 1956\ANONJA72BI1FH Male 1956 'HEAD PERFUSION'";

%% Initialize Data Structure
% Create the main structure to store all processed data
Male_1956 = struct();
Male_1956.CTA = {};          % Will store filtered CTA images
Male_1956.CTP = cell(1, 23); % 23 cells for unique CTP locations
ctpLocations = [];           % Array to store CTP Z-axis locations

%% Process CTP Images
% First pass: Collect and organize all CTP images by their location
fprintf('Processing CTP images...\n');
ctpFiles = dir(fullfile(ctpFolderPath, '*'));

for i = 1:length(ctpFiles)
    % Skip directories and hidden files
    if ctpFiles(i).isdir || strcmp(ctpFiles(i).name, '.') || strcmp(ctpFiles(i).name, '..')
        continue;
    end
    
    % Construct full file path
    dicomFilePath = fullfile(ctpFiles(i).folder, ctpFiles(i).name);
    
    try
        % Read DICOM metadata
        fileInfo = dicominfo(dicomFilePath, 'UseDictionaryVR', true);
        
        % Process only if location information is available
        if isfield(fileInfo, 'ImagePositionPatient')
            location = fileInfo.ImagePositionPatient(3);  % Z-axis location
            
            % Find or create location index
            locationIndex = find(ctpLocations == location, 1);
            if isempty(locationIndex)
                ctpLocations(end+1) = location;  % Add new location
                locationIndex = length(ctpLocations);
                Male_1956.CTP{locationIndex} = {};  % Initialize cell array
            end
            
            % Store the image path
            Male_1956.CTP{locationIndex}{end+1} = dicomFilePath;
        end
    catch ME
        fprintf('Error processing CTP file: %s\nError: %s\n', ctpFiles(i).name, ME.message);
    end
end

% Sort CTP locations and ensure exactly 23 cells
[~, sortedIndices] = sort(ctpLocations);
Male_1956.CTP = Male_1956.CTP(sortedIndices);
Male_1956.CTP = Male_1956.CTP(1:min(23, length(Male_1956.CTP)));

%% Calculate CTA Location Range
% Define the valid range for CTA images based on CTP locations
ctaMinLocation = min(ctpLocations) - 2;
ctaMaxLocation = max(ctpLocations) + 2;
fprintf('CTA Location Range: %.1f to %.1f\n', ctaMinLocation, ctaMaxLocation);

%% Process CTA Images
% Second pass: Collect CTA images within the calculated range
fprintf('Processing CTA images...\n');
ctaFiles = dir(fullfile(ctaFolderPath, '*'));

for i = 1:length(ctaFiles)
    % Skip directories and hidden files
    if ctaFiles(i).isdir || strcmp(ctaFiles(i).name, '.') || strcmp(ctaFiles(i).name, '..')
        continue;
    end
    
    % Construct full file path
    dicomFilePath = fullfile(ctaFiles(i).folder, ctaFiles(i).name);
    fprintf('Processing CTA file: %s\n', dicomFilePath);
    
    try
        % Read DICOM metadata
        fileInfo = dicominfo(dicomFilePath, 'UseDictionaryVR', true);
        
        % Process only if location information is available
        if isfield(fileInfo, 'ImagePositionPatient')
            location = fileInfo.ImagePositionPatient(3);
            
            % Store if within valid range
            if location >= ctaMinLocation && location <= ctaMaxLocation
                Male_1956.CTA{end+1} = dicomFilePath;
            end
        end
    catch ME
        fprintf('Error processing CTA file: %s\nError: %s\n', ctaFiles(i).name, ME.message);
    end
end

%% Group CTA Images
% Sort and group CTA images into sets of four
fprintf('Grouping CTA images...\n');

if ~isempty(Male_1956.CTA)
    % Create structured array with locations for sorting
    ctaData = struct('Path', {}, 'Location', {});
    for i = 1:length(Male_1956.CTA)
        fileInfo = dicominfo(Male_1956.CTA{i}, 'UseDictionaryVR', true);
        ctaData(i).Path = Male_1956.CTA{i};
        ctaData(i).Location = fileInfo.ImagePositionPatient(3);
    end

    % Sort by location
    [~, order] = sort([ctaData.Location]);
    sortedCtaData = ctaData(order);

    % Group into sets of four
    groupSize = 4;
    numGroups = floor(length(sortedCtaData) / groupSize);
    Male_1956.CTA_of_fours = cell(1, numGroups);

    for i = 1:numGroups
        startIndex = (i - 1) * groupSize + 1;
        endIndex = startIndex + groupSize - 1;
        Male_1956.CTA_of_fours{i} = {sortedCtaData(startIndex:endIndex).Path};
    end
    
    fprintf('Successfully grouped %d sets of four CTA images.\n', numGroups);
else
    fprintf('Warning: No CTA images found in the specified range.\n');
end

%% Save Results
% Save the final structure to a MAT file
outputPath = fileparts(ctpFolderPath);
save(fullfile(outputPath, 'Male_1956.mat'), 'Male_1956');

%% Final Report
fprintf('\nProcess completed:\n');
fprintf('- Collected %d CTA images\n', length(Male_1956.CTA));
fprintf('- Processed %d unique CTP locations\n', length(Male_1956.CTP));
fprintf('- Created %d groups of four CTA images\n', length(Male_1956.CTA_of_fours));
fprintf('- Results saved to: %s\n', fullfile(outputPath, 'Male_1956.mat'));